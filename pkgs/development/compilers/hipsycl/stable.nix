{ stdenv, fetchFromGitHub
, cmake
, boost
, python3
, llvmPackages
, rocm-device-libs
, hip
, rocm-runtime, rocm-comgr
, gcc-unwrapped
, config
, hipCPU
}:

llvmPackages.stdenv.mkDerivation {
  name = "hipsycl";
  version = "stable-20201027";

  src = fetchFromGitHub {
    owner = "illuhad";
    repo = "hipSYCL";
    rev = "46bc9bde22056900f18b725776c6f6c660355e9a";
    sha256 = "1g9azxdh9adalb60ldwn1zqf5ix02ixxplskyp8masj3wqlldwbb";
  };

  nativeBuildInputs = [ 
    cmake
    python3
    llvmPackages.lld
  ];
  buildInputs = [
    llvmPackages.clang-unwrapped
    llvmPackages.llvm
    llvmPackages.openmp
    rocm-device-libs
    rocm-comgr
    boost
  ];
  propagatedBuildInputs = [
    hip
    rocm-device-libs
    llvmPackages.lld
    rocm-runtime
    rocm-comgr
    llvmPackages.clang
    llvmPackages.llvm
    llvmPackages.openmp
  ];

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=${llvmPackages.clang}/bin/clang"
    "-DCLANG_EXECUTABLE_PATH=${llvmPackages.clang}/bin/clang++"
    "-DCLANG_INCLUDE_PATH=${llvmPackages.clang-unwrapped}/lib/clang/10.0.1/include/.."
    "-DCMAKE_CXX_COMPILER=${llvmPackages.clang}/bin/clang++"
    "-DWITH_CUDA_BACKEND=NO"
    "-DWITH_ROCM_BACKEND=YES"
    "-DROCM_PATH=${rocm-device-libs}"
    "-DDEFAULT_GPU_ARCH=${builtins.elemAt config.rocmTargets 0}"
  ];

  prePatch = ''
    patchShebangs bin/syclcc-clang

    mkdir -p contrib
    ln -s ${hipCPU}/* contrib/hipCPU/
    mkdir -p contrib/HIP/include/
    ln -s ${hip}/include/hip contrib/HIP/include/

    substituteInPlace CMakeLists.txt \
        --replace "\"-rpath \$HIPSYCL_ROCM_LIB_PATH -L\$HIPSYCL_ROCM_LIB_PATH -lhip_hcc -lamd_comgr -lhsa-runtime64 -rpath \$HIPSYCL_ROCM_PATH/hcc/lib -L\$HIPSYCL_ROCM_PATH/hcc/lib -lmcwamp -lhc_am\"" \
                  "\"-rpath \''${ROCM_PATH}/lib -rpath \''${ROCM_PATH}/hip/lib -L\''${ROCM_PATH}/lib -L\''${ROCM_PATH}/hip/lib -lamdhip64\""
  '';
}
