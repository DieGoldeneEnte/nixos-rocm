{ stdenv
, hipsycl
, cmake
, boost
, hipsycl_platform ? "cpu"
, hipsycl_gpu_arch ? ""
}:

stdenv.mkDerivation {
  name = "test";
  src = "${hipsycl.src}/tests";

  nativeBuildInputs = [ hipsycl ];
  buildInputs = [
    cmake
    hipsycl
    boost
  ];

  cmakeFlags = [
    "-DhipSYCL_DIR=${hipsycl}/lib/cmake/"
  ];


  HIPSYCL_PLATFORM=hipsycl_platform;
  HIPSYCL_GPU_ARCH=hipsycl_gpu_arch;

  hardeningDisable = [ "fortify" "stackprotector" ];

  installPhase = ''
    mkdir $out
    find . -type f -executable ! -iname '*.out' ! -iname '*.bin' ! -iname '*.rule' -exec mv {} $out/ \;
    echo $HIPSYCL_PLATFORM
    echo $HIPSYCL_GPU_ARCH
  '';

}
