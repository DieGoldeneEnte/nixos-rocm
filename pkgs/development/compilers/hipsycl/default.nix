{ stdenv, fetchFromGitHub, cmake, python3
, device-libs
, llvm, clang, clang-unwrapped, openmp
, rocr, hip, hipCPU, boost
}:
stdenv.mkDerivation rec {
  name = "hipsycl";
  version = "20191217";
  src = fetchFromGitHub {
    owner = "illuhad";
    repo = "hipSYCL";
    rev = "11557a155f576b8cbf504ac8f0151d19b77f54dd";
    sha256 = "0n5qgypyx8qs43y18j1drnanhy7al7namhxn0yzgdws6z7lxsnyz";
  };

  nativeBuildInputs = [ cmake python3 ];
  buildInputs = [ clang openmp llvm hipCPU ];
  cmakeFlags = [
    "-DCLANG_INCLUDE_PATH=${clang-unwrapped}/lib/clang/${getVersion clang-unwrapped}/include"
    "-DWITH_CUDA_BACKEND=NO"
    "-DWITH_ROCM_BACKEND=YES"
    "-DROCM_PATH=${device-libs}"
  ];
  propagatedBuildInputs = [ hip rocr ];

  prePatch = ''
    patchShebangs bin
    mkdir -p contrib
    ln -s ${hipCPU}/* contrib/hipCPU/
    mkdir -p contrib/HIP/include/
    ln -s ${hip}/include/hip contrib/HIP/include/
  '';
}
