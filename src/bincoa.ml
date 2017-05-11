open Format
open Dba
open Dba_types


(* exceptions *)
exception Unhandled of string


(* utils *)
let wrap t st args = `Assoc [
    ("Type", `String t) ;
    ("SubType", `String st) ;
    ("Args", `List args)
  ]


(* translators *)
let json_endian endian =
  match endian with
  | Dba.LittleEndian -> wrap "Endian" "LittleEndian" []
  | Dba.BigEndian -> wrap "Endian" "BigEndian" []

let json_string s = `String s

let json_int i = `Int i

let json_size = json_int        (* TODO *)
  (* `Int (Basic_types.BitSize.to_int size) *)

(* TODO: all instructions is max 8 bytes as numbers *)
let json_addr a =
  `Int (Bigint.int_of_big_int (Bitvector.value_of a.base)), (* TODO big to int *)
  json_size (Bitvector.size_of a.base)

let json_unop op =
  let wrap t = "UnOp", (wrap "UnOpKind" t []) in

  match op with
  | Dba.UMinus -> wrap "NEG"
  | Dba.Not -> wrap "NOT"

let json_binop op =
  let wrap_bin t = "BinOp", (wrap "BinOpKind" t []) in
  let wrap_rel t = "RelOp", (wrap "RelOpKind" t []) in

  match op with
  | Dba.Plus -> wrap_bin "ADD"
  | Dba.Minus -> wrap_bin "SUB"
  | Dba.MultU -> wrap_bin "MUL"
  | Dba.MultS -> wrap_bin "MUL" (* TODO: coming new op *)
  | Dba.DivU -> wrap_bin "DIV"
  | Dba.DivS -> wrap_bin "SDIV"
  | Dba.ModU -> wrap_bin "MOD"
  | Dba.ModS -> wrap_bin "SMOD"
  | Dba.Or -> wrap_bin "OR"
  | Dba.And -> wrap_bin "AND"
  | Dba.Xor -> wrap_bin "XOR"
  | Dba.Concat -> wrap_bin "CONCAT"
  | Dba.LShift -> wrap_bin "SHL"
  | Dba.RShiftU -> wrap_bin "SHR"
  | Dba.RShiftS -> wrap_bin "SAR"
  | Dba.LeftRotate -> raise (Unhandled "LeftRotate")
  | Dba.RightRotate -> raise (Unhandled "RightRotate")
  | Dba.Eq -> wrap_rel "EQ"
  | Dba.Diff -> wrap_rel "NEQ"
  | Dba.LeqU -> wrap_rel "LE"
  | Dba.LtU -> wrap_rel "LT"
  | Dba.GeqU -> raise (Unhandled "GeqU")
  | Dba.GtU -> raise (Unhandled "GtU")
  | Dba.LeqS -> wrap_rel "SLE"
  | Dba.LtS -> wrap_rel "SLT"
  | Dba.GeqS -> raise (Unhandled "GeqS")
  | Dba.GtS -> raise (Unhandled "GtS")

let rec json_expr expr =
  let wrap_expr st args = wrap "Expr" st args in

  match expr with
  | Dba.ExprVar (name, size, tag) -> begin
      match tag with
      (* | Some _ -> raise (Unhandled "vartag") *) (* TODO: unhandled vartag *)
      | _ ->
        wrap_expr "Var" [wrap "Reg" "Variable" [json_string name ; json_size size]]
    end

  | Dba.ExprLoad (size, endian, e) ->
      wrap_expr "Load" [json_expr e ; json_endian endian ; json_size (size * 8)]

  | Dba.ExprCst (_, vector) ->
      let value = Bigint.int_of_big_int (Bitvector.value_of vector) in
      let size = Bitvector.size_of vector in
      wrap_expr "Num" [wrap "Imm" "Integer" [json_int value ; json_size size]]

  | Dba.ExprUnary (op, e) -> begin
      let op_s, op_json = json_unop op in
      wrap_expr op_s [op_json ; json_expr e]
    end

  | Dba.ExprBinary (op, e1, e2) -> begin
      match op with
      | Dba.GtU -> json_expr (Expr.unary Dba.Not (Expr.binary Dba.LeqU e1 e2))
      | Dba.GeqU -> json_expr (Expr.unary Dba.Not (Expr.binary Dba.LtU e1 e2))
      | Dba.GtS -> json_expr (Expr.unary Dba.Not (Expr.binary Dba.LeqS e1 e2))
      | Dba.GeqS -> json_expr (Expr.unary Dba.Not (Expr.binary Dba.LtS e1 e2))
      | _ ->
          let op_s, op_json = json_binop op in
          wrap_expr op_s [op_json ; json_expr e1 ; json_expr e2]
    end

  | Dba.ExprRestrict (expr, lo, hi) ->
      let c' = wrap_expr "Cast" [
        (wrap "CastFrom" "Low" []) ;
        json_int (hi + 1) ;
        json_expr expr
      ] in
      wrap_expr "Cast" [
        (wrap "CastFrom" "High" []) ;
        json_int (hi - lo + 1) ;
        c'
      ]

  | Dba.ExprExtU (expr, size) ->
      wrap_expr "Cast" [(wrap "CastFrom" "ZeroExt" []) ; json_size size ; json_expr expr]

  | Dba.ExprExtS (expr, size) ->
      wrap_expr "Cast" [(wrap "CastFrom" "SignExt" []) ; json_size size ; json_expr expr]

  | Dba.ExprIte (c, e1, e2) ->
      wrap_expr "Ite" [json_cond c ; json_expr e1 ; json_expr e2]

  | Dba.ExprAlternative (_, _) -> raise (Unhandled "ExprAlternative")
    (* let op_s, op_json = json_binop Dba.Concat in *)
    (* let rec fold exprs = *)
    (*   match exprs with *)
    (*   | [] -> raise (Unhandled "empty ExprAlternative") *)
    (*   | [e] -> json_expr e *)
    (*   | e :: es -> wrap_expr op_s ([op_json ; json_expr e] @ [fold es]) *)
    (* in *)
    (* fold exprs *)

and json_cond cond =
  match cond with
  | Dba.CondReif (e) -> json_expr e
  | Dba.CondNot (c) ->
      let op_s, op_json = json_unop Dba.Not in
      wrap "Expr" op_s [op_json ; json_cond c]
  | Dba.CondAnd (c1, c2) ->
      let op_s, op_json = json_binop Dba.And in
      wrap "Expr" op_s [op_json ; json_cond c1 ; json_cond c2]
  | Dba.CondOr (c1, c2) ->
      let op_s, op_json = json_binop Dba.Or in
      wrap "Expr" op_s [op_json ; json_cond c1 ; json_cond c2]
  | Dba.True ->
      wrap "Expr" "Num" [wrap "Imm" "Integer" [json_int 1 ; json_size 1]]
  | Dba.False ->
      wrap "Expr" "Num" [wrap "Imm" "Integer" [json_int 0 ; json_size 1]]

let json_lhs lhs =
  match lhs with
  | Dba.LhsVar (name, size, _) ->
      wrap "Reg" "Variable" [json_string name ; json_size size]
  | Dba.LhsVarRestrict (name, size, _, _) ->
      wrap "Reg" "Variable" [json_string name ; json_size size]
  | Dba.LhsStore (_, _, _) -> raise (Unhandled "LhsStore")

let json_target target =
  let num = match target with
    | Dba.JInner (id) ->
      wrap "Imm" "Integer" [json_int id ; json_int 8]
    | Dba.JOuter (addr) ->
      let i_json, s_json = json_addr addr in
      wrap "Imm" "Integer" [i_json ; s_json]
  in
  wrap "Expr" "Num" [num]

let unrestrict lhs expr name size lo hi =
  let lhs = Dba.LhsVar (name, size, None) in
  let v = Dba.ExprVar (name, size, None) in
  let expr = Dba.ExprBinary (Dba.Concat,
                             Dba.ExprRestrict (v, hi + 1, size - 1),
                             expr) in
  lhs, expr

let json_stmt (num, idx, res) s =
  let wrap_stmt st args = wrap "Stmt" st args in

  match s with
  | Dba.IkAssign (lhs, expr, _) -> begin
      let j = match lhs with
      | Dba.LhsVar (_, _, _) ->
          wrap_stmt "Move" [json_lhs lhs ; json_expr expr]
      | Dba.LhsVarRestrict (name, size, l, h) ->
          let lhs, expr = unrestrict lhs expr name size l h in
          wrap_stmt "Move" [json_lhs lhs ; json_expr expr]
      | Dba.LhsStore (_, endian, e2) ->
          wrap_stmt "Store" [json_expr e2 ; json_endian endian ; json_expr expr]
      in
      (num, idx, j :: res)
    end

  | Dba.IkSJump (target, _) ->
      let e = json_target target in
      let j = wrap_stmt "End" [e] in
      (num, idx, j :: res)

  | Dba.IkDJump (expr, _) ->
      let j = wrap_stmt "End" [json_expr expr] in
      (num, idx, j :: res)

  | Dba.IkIf (cond, target, _) ->
      let c = json_cond cond in
      let s1 = json_string (sprintf "Label%d" idx) in
      let s2 = json_string (sprintf "Label%d" (idx + 1)) in
      let lab1 = wrap_stmt "Label" [s1] in
      let lab2 = wrap_stmt "Label" [s2] in
      let swt = wrap_stmt "CJump" [c ; s1 ; s2] in
      let jmp = wrap_stmt "End" [json_target target] in
      (num, idx + 2, lab2 :: jmp :: lab1 :: swt :: res)

  | Dba.IkStop (_) ->
      (num, idx, (wrap_stmt "End" [num]) :: res)

  | Dba.IkAssert (_, _) -> raise (Unhandled "IkAssert")
  | Dba.IkAssume (_, _) -> raise (Unhandled "IkAssume")
  | Dba.IkNondetAssume (_, _, _) -> raise (Unhandled "IkNondetAssume")
  | Dba.IkNondet (_, _, _) -> raise (Unhandled "IkNondet")

  | Dba.IkUndef (lhs, _) ->
      let j = wrap_stmt "Move" [json_lhs lhs ; wrap "Expr" "NotExpr" []] in
      (num, idx, j :: res)

  | Dba.IkMalloc (_, _, _) -> raise (Unhandled "IkMalloc")
  | Dba.IkFree (_, _) -> raise (Unhandled "IkFree")
  | Dba.IkPrint (_, _) -> raise (Unhandled "IkPrint")

let json_ast addr len dba =
  let imm = wrap "Imm" "Integer" [`Int (addr + len) ; `Int 32] in
  let num = wrap "Expr" "Num" [imm] in
  let _, _, rev_stmts = Block.fold_left json_stmt (num, 0, []) dba in
  (* let _, _, rev_stmts = json_stmt (num, 0, []) (Block.get dba 0) in *)
  let rev_stmts' =
    match rev_stmts with
    | [] -> [wrap "Stmt" "End" [num]]
    | (`Assoc [("Type", `String "Stmt") ; ("SubType", `String "End") ; _]) :: _ -> rev_stmts
    | _ :: _ -> (wrap "Stmt" "End" [num]) :: rev_stmts
  in
  wrap "AST" "Stmts" (List.rev rev_stmts')


(* main *)
let _ =
  (* comment out to hide debug output *)
  Logger.set_log_level "debug";

  (* lift instruction *)
  let opc, dba = Decode_utils.decode_hex_opcode Sys.argv.(1) in

  (* print dba *)
  Logger.debug "\n\n%s\n==================================================================" opc;
  Block.iter (fun i -> Logger.debug "%a" Dba_printer.Ascii.pp_instruction i) dba;
  Logger.debug "\n\n";

  (* variables *)
  let addr = 0x8048000 in
  let len = (Block.length dba) * 32 in

  (* debug ExprAlternative *)
  (* let foo = Dba.ExprAlternative ([ *)
  (*     (Dba.ExprUnary (Dba.Not, (Dba.ExprVar ("foo", 1, None)))) ; *)
  (*     (Dba.ExprUnary (Dba.Not, (Dba.ExprVar ("foo", 1, None)))) ; *)
  (*     (Dba.ExprUnary (Dba.Not, (Dba.ExprVar ("foo", 1, None)))) *)
  (*   ], None) in *)
  (* let foo = Dba.ExprAlternative ([(Dba.ExprVar ("foo", 1, None))], None) in *)
  (* let json = json_expr foo in *)

  (* debug IkIf *)
  (* let foo = Dba.IkIf ((Dba.True), (Dba.JInner (42)), 7) in *)
  (* let json = json_ast addr len (Block.of_list [foo ; (Dba.IkStop (None))]) in *)

  (* translate into json *)
  let json = json_ast addr len dba in

  (* print the list, line by line *)
  Logger.debug "\n==================================================================";
  print_endline (Yojson.Basic.pretty_to_string json)
