##########################################################################
#  This file is part of Binsec.                                          #
#                                                                        #
#  Copyright (C) 2016-2017                                               #
#    CEA (Commissariat à l'énergie atomique et aux énergies              #
#         alternatives)                                                  #
#                                                                        #
#  you can redistribute it and/or modify it under the terms of the GNU   #
#  Lesser General Public License as published by the Free Software       #
#  Foundation, version 2.1.                                              #
#                                                                        #
#  It is distributed in the hope that it will be useful,                 #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#  GNU Lesser General Public License for more details.                   #
#                                                                        #
#  See the GNU Lesser General Public License version 2.1                 #
#  for more details (enclosed in the file licenses/LGPLv2.1).            #
#                                                                        #
##########################################################################

OPTION_FILES =
GENERATED_FILES =


BINSEC_LICENSE_CEA =
BINSEC_LICENSE_CEA_IMAG =
BINSEC_LICENSE_IMAG =
BINSEC_LICENSE_EXTERNAL_CHLIPALA =


BUILD_FILES = \
	_tags Makefile Targets.mk
BINSEC_DISTRIB_FILES += $(BUILD_FILES)
BINSEC_LICENSE_CEA += $(BUILD_FILES)


DBA_DIR = dba
DBA_SRC_FILES = dba_printer dba_types errors dba_utils dba_visitor
DBA_INT_FILES = sigs dba
DBA_ML_FILES = $(DBA_SRC_FILES:%=$(DBA_DIR)/%.ml)
DBA_MLI_FILES = \
	$(DBA_SRC_FILES:%=$(DBA_DIR)/%.mli) \
	$(DBA_INT_FILES:%=$(DBA_DIR)/%.mli)
DBA_FILES = $(DBA_ML_FILES) $(DBA_MLI_FILES)
BINSEC_DISTRIB_FILES += $(DBA_FILES)
BINSEC_LICENSE_CEA += $(DBA_FILES)


UTILS_DIR = utils
UTILS_SRC_FILES = \
	colors \
	binsec_utils \
	smt_bitvectors region_bitvector \
	network_io \
	parse_utils instParsing
UTILS_ML_FILES = $(UTILS_SRC_FILES:%=$(UTILS_DIR)/%.ml)
UTILS_MLI_FILES = \
	$(UTILS_INT_FILES:%=$(UTILS_DIR)/%.mli) \
	$(UTILS_ML_FILES:%.ml=%.mli)


UTILS_BASE_DIR = base
UTILS_BASE_SRC_FILES = \
	bigint bitvector string_utils \
	logger \
	basic_types \
	parameters \
	list_utils print_utils file_utils \
	machine \
	worklist \
	utils
UTILS_BASE_ML_FILES = $(UTILS_BASE_SRC_FILES:%=$(UTILS_BASE_DIR)/%.ml)
UTILS_BASE_MLI_FILES = $(UTILS_BASE_ML_FILES:%.ml=%.mli)
ALL_UTILS_ML_FILES = \
	$(UTILS_BASE_ML_FILES) \
	$(UTILS_ML_FILES)
ALL_UTILS_MLI_FILES = $(UTILS_BASE_MLI_FILES) $(UTILS_MLI_FILES)

BINSEC_DISTRIB_FILES += \
	$(ALL_UTILS_ML_FILES) $(ALL_UTILS_MLI_FILES)

BINSEC_LICENSE_CEA += \
	$(ALL_UTILS_ML_FILES) $(ALL_UTILS_MLI_FILES)


##
# Loader
##
LOADER_DIR = loader
LOADER_SRC_FILES = loader_types loader_buf loader_elf loader_pe loader loader_utils
LOADER_INT_FILES = loader_sigs
LOADER_ML_FILES = $(LOADER_SRC_FILES:%=$(LOADER_DIR)/%.ml)
LOADER_MLI_FILES = \
	$(LOADER_INT_FILES:%=$(LOADER_DIR)/%.mli) \
	$(LOADER_ML_FILES:%.ml=%.mli)
LOADER_CAML_FILES = $(LOADER_ML_FILES) $(LOADER_MLI_FILES)

BINSEC_DISTRIB_FILES += $(LOADER_CAML_FILES)
BINSEC_LICENSE_CEA +=  $(LOADER_CAML_FILES)

##
# Disassembly & subdirs
##
DISASM_DIR = disasm

# Disasm_options depends on X86Types ... this should be done better
OPTION_FILES += $(DISASM_DIR)/disasm_options $(DISASM_DIR)/disasm_types

X86_DIR = $(DISASM_DIR)/x86
X86_INT_FILES = x86Types
X86_EXT_SRC_FILES = lreader x86Util x86pp
X86_OWN_SRC_FILES = predba x86Instruction x86decoder x86toDba
X86_SRC_FILES = \
	$(X86_EXT_SRC_FILES) \
	$(X86_OWN_SRC_FILES)
X86_ML_FILES = $(X86_SRC_FILES:%=$(X86_DIR)/%.ml)
X86_MLI_FILES = \
	$(X86_INT_FILES:%=$(X86_DIR)/%.mli) \
	$(X86_SRC_FILES:%=$(X86_DIR)/%.mli)
X86_FILES = $(X86_MLI_FILES) $(X86_ML_FILES)

BINSEC_DISTRIB_FILES += $(X86_FILES)

ARM_DIR = $(DISASM_DIR)/arm
ARM_SRC_FILES = armToDba
ARM_MLI_FILES = $(ARM_SRC_FILES:%=$(ARM_DIR)/%.mli)
ARM_ML_FILES = $(ARM_SRC_FILES:%=$(ARM_DIR)/%.ml)
ARM_FILES = $(ARM_MLI_FILES) $(ARM_ML_FILES)

BINSEC_DISTRIB_FILES += $(ARM_FILES)

BINSEC_LICENSE_CEA +=  \
	$(X86_DIR)/lreader.ml $(X86_DIR)/lreader.mli \
	$(X86_OWN_SRC_FILES:%=$(X86_DIR)/%.ml) \
	$(X86_OWN_SRC_FILES:%=$(X86_DIR)/%.mli) \
	$(ARM_FILES)

BINSEC_EXTERNAL = \
	$(X86_EXT_SRC_FILES:%=$(X86_DIR)/%.ml) \
	$(X86_EXT_SRC_FILES:%=$(X86_DIR)/%.mli)

SIMP_DIR = $(DISASM_DIR)/simplify

SIMP_SRC_FILES = \
	simplification_dba_utils \
	simplification_dba_block \
	simplification_dba_instr \
	simplification_dba_prog \
	simplification_dba

SIMP_ML_FILES = $(SIMP_SRC_FILES:%=$(SIMP_DIR)/%.ml)
SIMP_MLI_FILES = $(SIMP_INT_FILES) $(SIMP_SRC_FILES:%=$(SIMP_DIR)/%.mli)
SIMP_FILES = $(SIMP_MLI_FILES) $(SIMP_ML_FILES)

BINSEC_LICENSE_CEA +=  $(SIMP_FILES)
BINSEC_DISTRIB_FILES +=  $(SIMP_FILES)

DISASM_OWN_SRC_FILES = \
	disasm_dyn_infos_callrets \
	decode_utils \
	disasm_core \
	disasm \
	disasm_cfg
DISASM_SRC_FILES = \
	$(DISASM_EXT_SRC_FILES) \
	$(DISASM_OWN_SRC_FILES)
DISASM_ML_FILES = $(DISASM_SRC_FILES:%=$(DISASM_DIR)/%.ml)
DISASM_MLI_FILES = \
	$(DISASM_ML_FILES:%.ml=%.mli) \
	$(DISASM_INT_FILES:%=$(DISASM_DIR)/%.mli)

DISASM_FILES = $(DISASM_MLI_FILES) $(DISASM_ML_FILES)

BINSEC_DISTRIB_FILES += $(DISASM_FILES)

BINSEC_LICENSE_CEA += $(DISASM_FILES)


##
# SMT
##

SMT_DIR = smtutils
SMT_PRE_SRC_FILES = locations
SMT_PRE_ML_FILES = $(SMT_PRE_SRC_FILES:%=$(SMT_DIR)/%.ml)
SMT_SRC_FILES = \
	smtlib2 smtlib2print smtlib2_visitor \
	dba_to_smtlib smtlib_pp smt_model solver
SMT_INT_FILES = $(SMT_SRC_FILES) locations smtlib_ast
SMT_PARSER_FILES = smtlib_parser
SMT_LEXER_FILES = smtlib_lexer
SMT_GENERATED_ML_FILES = \
	$(SMT_PARSER_FILES:%=$(SMT_DIR)/%.ml) \
	$(SMT_LEXER_FILES:%=$(SMT_DIR)/%.ml)

SMT_GENERATED_MLI_FILES = \
	$(SMT_PARSER_FILES:%=$(SMT_DIR)/%.mli)

SMT_ML_FILES = \
	$(SMT_PRE_ML_FILES) \
	$(SMT_GENERATED_ML_FILES) \
	$(SMT_SRC_FILES:%=$(SMT_DIR)/%.ml)

SMT_MLI_FILES = \
	$(SMT_GENERATED_MLI_FILES) \
	$(SMT_INT_FILES:%=$(SMT_DIR)/%.mli)

GENERATED_FILES += \
	$(SMT_GENERATED_MLI_FILES) \
	$(SMT_GENERATED_ML_FILES)

SMT_FILES = \
	$(SMT_PRE_ML_FILES) \
	$(SMT_SRC_FILES:%=$(SMT_DIR)/%.ml) \
	$(SMT_INT_FILES:%=$(SMT_DIR)/%.mli) \
	$(SMT_PARSER_FILES:%=$(SMT_DIR)/%.mly) \
	$(SMT_LEXER_FILES:%=$(SMT_DIR)/%.mll)

BINSEC_DISTRIB_FILES += $(SMT_FILES)
BINSEC_LICENSE_CEA += $(SMT_FILES)


# Licenses
BINSEC_LICENSE_CEA += \
	$(DTRACE_BASE_ML_FILES) \
	$(DTRACE_BASE_MLI_FILES) \
	$(DTRACE_ML_FILES) \
	$(DTRACE_MLI_FILES) \
	$(DDSE_LIBCALL_SRC_FILES_CEA:%=$(DDSE_LIBCALL_DIR)/%.ml) \
	$(DDSE_LIBCALL_SRC_FILES_CEA:%=$(DDSE_LIBCALL_DIR)/%.mli) \
	$(DDSE_SYSCALL_ML_FILES) \
	$(DDSE_SYSCALL_MLI_FILES) \
	$(DDSE_ISTUBS_ML_FILES) \
	$(DDSE_ISTUBS_MLI_FILES) \
	$(DTAINT_MLI_FILES) \
	$(DTAINT_ML_FILES) \
	$(DDSE_ML_FILES) \
	$(DDSE_MLI_FILES) \
	$(DDSE_EXAMPLES_ML_FILES) \
	$(DDSE_EXAMPLES_MLI_FILES)

BINSEC_LICENSE_CEA_IMAG += \
	$(DDSE_LIBCALL_SRC_FILES_CEA_IMAG:%=$(DDSE_LIBCALL_DIR)/%.ml) \
	$(DDSE_LIBCALL_SRC_FILES_CEA_IMAG:%=$(DDSE_LIBCALL_DIR)/%.mli)

BINSEC_LICENSE_IMAG += $(DPATH_FILES)

##
# DSE
#

# Unused files: typeHeuristiDSE guideasDFSUAF invertSAT exploit_analyse


##
# Parsers
##
PARSER_DIR = parser
PARSER_PARSER_FILES = dbacsl_parser parser parser_infos policy_parser SMTParserWp
PARSER_LEXER_FILES = dbacsl_token lexer lexer_infos policy_token SMTLexerWp
PARSER_SRC_FILES = parse_helpers
PARSER_GENERATED_ML_FILES = \
	$(PARSER_PARSER_FILES:%=$(PARSER_DIR)/%.ml) \
	$(PARSER_LEXER_FILES:%=$(PARSER_DIR)/%.ml)
PARSER_GENERATED_MLI_FILES = \
	$(PARSER_PARSER_FILES:%=$(PARSER_DIR)/%.mli)
PARSER_ML_FILES = \
	$(PARSER_SRC_FILES:%=$(PARSER_DIR)/%.ml) \
	$(PARSER_GENERATED_ML_FILES)
# Weirdly enough, ocamllex does not generate mli
PARSER_MLI_FILES = \
	$(PARSER_GENERATED_MLI_FILES) \
	$(PARSER_SRC_FILES:%=$(PARSER_DIR)/%.mli)
GENERATED_FILES += \
	$(PARSER_GENERATED_ML_FILES) \
	$(PARSER_GENERATED_MLI_FILES)

PARSER_FILES = \
	$(PARSER_PARSER_FILES:%=$(PARSER_DIR)/%.mly) \
	$(PARSER_LEXER_FILES:%=$(PARSER_DIR)/%.mll) \
	$(PARSER_SRC_FILES:%=$(PARSER_DIR)/%.ml) \
	$(PARSER_SRC_FILES:%=$(PARSER_DIR)/%.mli)

BINSEC_DISTRIB_FILES += $(PARSER_FILES)
BINSEC_LICENSE_CEA += $(PARSER_FILES)



# License ?


BINPATCHER_DIR = binpatcher
OPTION_FILES += $(BINPATCHER_DIR)/binpatcher_options
BINPATCHER_SRC_FILES = binpatcher
BINPATCHER_INT_FILES = $(BINPATCHER_SRC_FILES)
BINPATCHER_ML_FILES = $(BINPATCHER_SRC_FILES:%=$(BINPATCHER_DIR)/%.ml)
BINPATCHER_MLI_FILES = $(BINPATCHER_INT_FILES:%=$(BINPATCHER_DIR)/%.mli)
BINPATCHER_FILES = \
	$(BINPATCHER_ML_FILES) \
	$(BINPATCHER_MLI_FILES) 

BINSEC_DISTRIB_FILES += $(BINPATCHER_FILES)
BINSEC_LICENSE_CEA   += $(BINPATCHER_FILES)



ROOT_SRC_FILES = infos
ROOT_INT_FILES = infos
ROOT_ML_FILES = $(ROOT_SRC_FILES:%=%.ml)
ROOT_MLI_FILES = $(ROOT_INT_FILES:%=%.mli)
MAIN_ML_FILES = test.ml main.ml

BINSEC_LICENSE_CEA += \
	$(ROOT_MLI_FILES) \
	$(ROOT_ML_FILES) $(MAIN_ML_FILES) test.mli

BINSEC_DISTRIB_FILES += $(ROOT_ML_FILES) $(MAIN_ML_FILES)

OPTION_FILES += options
OPTION_ML_FILES = $(OPTION_FILES:%=%.ml)
OPTION_MLI_FILES = $(OPTION_FILES:%=%.mli)

BINSEC_LICENSE_CEA += \
	$(OPTION_ML_FILES) \
	$(OPTION_MLI_FILES)

SHARE_DIR = share
BINSEC_DISTRIB_FILES += $(SHARE_DIR)

BINSEC_DISTRIB_FILES += $(OPTION_ML_FILES) $(OPTION_MLI_FILES)

ML_FILES = \
	$(UTILS_BASE_ML_FILES) \
	$(DBA_ML_FILES) \
	config.ml \
	$(OPTION_ML_FILES) \
	$(LOADER_ML_FILES) \
	$(ROOT_ML_FILES) \
	$(PARSER_ML_FILES) \
	$(SMT_ML_FILES) \
	$(UTILS_ML_FILES) \
	$(DISASM_BASE_ML_FILES) \
	$(AST_ML_FILES) \
	$(X86_ML_FILES) \
	$(ARM_ML_FILES) \
	$(SIMP_ML_FILES) \
	$(LLVM_ML_FILES) \
	$(DISASM_ML_FILES) \
	$(MAIN_ML_FILES)


MLI_FILES = \
	$(ALL_UTILS_MLI_FILES) \
	$(STATIC_MLI_FILES) \
	$(OPTION_MLI_FILES) \
	$(DBA_MLI_FILES) \
	$(LOADER_MLI_FILES) \
	$(FORMULA_MLI_FILES) \
	$(PARSER_MLI_FILES) \
	$(SMT_MLI_FILES) \
	$(AST_MLI_FILES) \
	$(X86_MLI_FILES) \
	$(ARM_MLI_FILES) \
	$(SIMP_MLI_FILES) \
	$(DISASM_MLI_FILES) \
	$(ALL_AI_MLI_FILES) \
	$(SIMULATION_MLI_FILES) \
	$(DYNAMIC_MLI_FILES) \
	$(LLVM_MLI_FILES) \
	$(SERVER_MLI_FILES) \
	$(EXAMPLE_MLI_FILES) \
	$(BINPATCHER_MLI_FILES) \
	test.mli \
	$(ROOT_MLI_FILES)


CMO_FILES = $(ML_FILES:%.ml=%.cmo)
CMX_FILES = $(ML_FILES:%.ml=%.cmx)
CMI_FILES = $(MLI_FILES:%.ml=%.cmi)

DIRS = \
	$(UTILS_BASE_DIR) \
	$(UTILS_DIR) \
	$(DBA_DIR) \
	$(FORMULA_DIR) \
	$(AST_DIR) \
	$(X86_DIR) \
	$(SIMP_DIR) \
	$(DISASM_DIR) \
	$(STATIC_DIR) \
	$(PARSER_DIR) \
	$(AI_DIR) $(AI_DOMAINS_DIR)\
	$(SIMULATION_DIR) \
	$(LOADER_DIR) \
	$(DYNAMIC_DIRS) \
	$(SMT_DIR) $(SMT_PARSER_DIR) \
	$(EXAMPLE_DIR) \
	$(SERVER_DIR) \
	$(PIQI_DIR) \
	$(DSE_DIR) \
	$(ARM_DIR) \
	$(LLVM_DIR) \
	$(BINPATCHER_DIR)


CAMLINCLUDES = $(DIRS:%=-I %) -I .
CAMLFILES = $(MLI_FILES) $(ML_FILES)
