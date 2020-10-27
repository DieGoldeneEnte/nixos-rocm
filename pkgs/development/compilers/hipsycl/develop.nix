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
}:

llvmPackages.stdenv.mkDerivation {
  name = "hipsycl";
  version = "develop-20201027";

  src = fetchFromGitHub {
    owner = "illuhad";
    repo = "hipSYCL";
    rev = "4aea57afbd37faa241b0dfe67088e66fa11b55de";
    sha256 = "1yx2q3cw5mv8yi7i7r1x7kd94qv1p60s3wicgwgwm5h2l53adsln";
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
    "-DCLANG_INCLUDE_PATH=${llvmPackages.clang-unwrapped}/lib/clang/${llvmPackages.clang.version}/include/.."
    "-DCMAKE_CXX_COMPILER=${llvmPackages.clang}/bin/clang++"
    "-DWITH_CUDA_BACKEND=NO"
    "-DWITH_ROCM_BACKEND=YES"
    "-DROCM_PATH=${rocm-device-libs}"
    "-DDEFAULT_GPU_ARCH=${builtins.elemAt config.rocmTargets 0}"
  ];

  prePatch = ''
    patchShebangs bin
    patchShebangs cmake/syclcc-launcher
  '';
}
