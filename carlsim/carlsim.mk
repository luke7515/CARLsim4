##----------------------------------------------------------------------------##
##
##   CARLsim4 Kernel
##   ---------------
##
##   Authors:   Michael Beyeler <mbeyeler@uci.edu>
##              Kristofor Carlson <kdcarlso@uci.edu>
##              Ting-Shuo Chou <tingshuc@uci.edu>
##
##   Institute: Cognitive Anteater Robotics Lab (CARL)
##              Department of Cognitive Sciences
##              University of California, Irvine
##              Irvine, CA, 92697-5100, USA
##
##   Version:   12/31/2016
##
##----------------------------------------------------------------------------##

#------------------------------------------------------------------------------
# CARLsim4 Interface
#------------------------------------------------------------------------------

intf_dir          := carlsim/interface
intf_inc_files    := $(wildcard $(intf_dir)/inc/*.h)
intf_cpp_files    := $(wildcard $(intf_dir)/src/*.cpp)
intf_cu_files     := $(wildcard $(intf_dir)/src/*.cu)
intf_cpp_obj      := $(patsubst %.cpp, %-cpp.o, $(intf_cpp_files))
intf_cu_obj       := $(patsubst %.cu, %-cu.o, $(intf_cu_files))
SIMINCFL          += -I$(intf_dir)/inc


#------------------------------------------------------------------------------
# CARLsim4 Kernel
#------------------------------------------------------------------------------

krnl_dir          := carlsim/kernel
krnl_inc_files    := $(wildcard $(krnl_dir)/inc/*.h)
krnl_cpp_files    := $(wildcard $(krnl_dir)/src/*.cpp)
krnl_cu_files     := $(wildcard $(krnl_dir)/src/gpu_module/*.cu)
krnl_cpp_obj      := $(patsubst %.cpp, %-cpp.o, $(krnl_cpp_files))
krnl_cu_obj       := $(patsubst %.cu, %-cu.o, $(krnl_cu_files))
SIMINCFL          += -I$(krnl_dir)/inc


#------------------------------------------------------------------------------
# CARLsim4 Utilities
#------------------------------------------------------------------------------

mon_dir          := carlsim/monitor
mon_inc_files    := $(wildcard $(mon_dir)/*.h)
mon_cpp_files    := $(wildcard $(mon_dir)/*.cpp)
mon_cu_files     := $(wildcard $(mon_dir)/src/*.cu)
mon_cpp_obj      := $(patsubst %.cpp, %-cpp.o, $(mon_cpp_files))
mon_cu_obj       := $(patsubst %.cu, %-cu.o, $(mon_cu_files))
SIMINCFL         += -I$(mon_dir)


#------------------------------------------------------------------------------
# CARLsim4 Tools
#------------------------------------------------------------------------------

tools_cpp_obj    :=
tools_cu_obj     :=

# simple weight tuner
swt_dir          := tools/simple_weight_tuner
swt_inc_files    := $(wildcard $(swt_dir)/*h)
swt_cpp_files    := $(wildcard $(swt_dir)/*.cpp)
swt_cu_files     := $(wildcard $(swt_dir)/*.cu)
swt_cpp_obj      := $(patsubst %.cpp, %.o, $(swt_cpp_files))
tools_cpp_obj    += $(swt_cpp_obj)
SIMINCFL         += -I$(swt_dir)

# spike generators
spkgen_dir       := tools/spike_generators
spkgen_inc_files := $(wildcard $(spkgen_dir)/*.h)
spkgen_cpp_files := $(wildcard $(spkgen_dir)/*.cpp)
spkgen_cpp_obj   := $(patsubst %.cpp, %.o, $(spkgen_cpp_files))
tools_cpp_obj    += $(spkgen_cpp_obj)
SIMINCFL         += -I$(spkgen_dir)

# stopwatch
stp_dir          := tools/stopwatch
stp_inc_files    := $(wildcard $(stp_dir)/*h)
stp_cpp_files    := $(wildcard $(stp_dir)/*.cpp)
stp_cpp_obj      := $(patsubst %.cpp, %.o, $(stp_cpp_files))
tools_cpp_obj    += $(stp_cpp_obj)
SIMINCFL         += -I$(stp_dir)


#------------------------------------------------------------------------------
# CARLsim4 Common
#------------------------------------------------------------------------------

outputs         += carlsim4
objects_cpp     += $(krnl_cpp_obj) $(intf_cpp_obj) $(mon_cpp_obj) $(tools_cpp_obj)
objects_cu      += $(krnl_cu_obj) $(intf_cu_obj) $(mon_cu_obj) $(tools_cu_obj)

# list of objects depend on build mode
ifeq ($(CARLSIM4_NO_CUDA),1)
objects         := $(objects_cpp)
else
objects         := $(objects_cpp) $(objects_cu)
endif

# additional files that need to be installed
add_files       := $(addprefix carlsim/,configure.mk)


#------------------------------------------------------------------------------
# CARLsim4 Targets
#------------------------------------------------------------------------------

.PHONY: release debug archive 

release: CXXFL  += -O3 -ffast-math
ifeq ($(CARLSIM4_NO_CUDA),1)
release: NVCCFL += -O3 -ffast-math
else
release: NVCCFL += --compiler-options "-O3 -ffast-math"
endif
release: $(objects)
release: archive

debug: CXXFL    += -g -Wall -O0
ifeq ($(CARLSIM4_NO_CUDA),1)
debug: NVCCFL   += -g -Wall -O0
else
debug: NVCCFL   += -g -G --compiler-options "-Wall -O0"
endif
debug: $(objects)
debug: archive



#------------------------------------------------------------------------------
# CARLsim4 Rules
#------------------------------------------------------------------------------

# rule to compile local cpps
$(intf_dir)/src/%-cpp.o: $(intf_dir)/src/%.cpp $(intf_inc_files)
	$(NVCC) $(NVCCSHRFL) -c $(NVCCINCFL) $(SIMINCFL) $(NVCCFL) $< -o $@
$(intf_dir)/src/%-cu.o: $(intf_dir)/src/%.cu $(intf_inc_files)
	$(NVCC) $(NVCCSHRFL) -c $(NVCCINCFL) $(SIMINCFL) $(NVCCFL) $< -o $@
$(krnl_dir)/src/%-cpp.o: $(krnl_dir)/src/%.cpp $(krnl_inc_files)
	$(NVCC) $(NVCCSHRFL) -c $(NVCCINCFL) $(SIMINCFL) $(NVCCFL) $< -o $@
$(krnl_dir)/src/gpu_module/%-cu.o: $(krnl_dir)/src/gpu_module/%.cu $(krnl_inc_files)
	$(NVCC) $(NVCCSHRFL) -c $(NVCCINCFL) $(SIMINCFL) $(NVCCFL) $< -o $@

# utilities
$(mon_dir)/%-cpp.o: $(mon_dir)/%.cpp $(mon_inc_files)
	$(NVCC) $(NVCCSHRFL) -c $(NVCCINCFL) $(SIMINCFL) $(NVCCFL) $< -o $@

# tools
$(swt_dir)/%.o: $(swt_dir)/%.cpp $(swt_inc_files)
	$(CXX) $(CXXSHRFL) -c $(CXXINCFL) $(SIMINCFL) $(CXXFL) $< -o $@
$(spkgen_dir)/%.o: $(spkgen_dir)/%.cpp $(spkgen_inc_files)
	$(CXX) $(CXXSHRFL) -c $(CXXINCFL) $(SIMINCFL) $(CXXFL) $< -o $@
$(stp_dir)/%.o: $(stp_dir)/%.cpp $(stp_inc_files)
	$(CXX) $(CXXSHRFL) -c $(CXXINCFL) $(SIMINCFL) $(CXXFL) $< -o $@

# archive
archive: $(objects)
	ar rcs $(lib_name).$(lib_ver) $(objects)
