{stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation {
  name = "hipCPU";
  version = "20200930";

  src = fetchFromGitHub {
    owner = "illuhad";
    repo = "hipCPU";
    rev = "0aa4e2c0a7f83956c0948e0d34aff0e3f233b406";
    sha256 = "1vj9vqgh3bkncgm912s4fkz0s9dkkmqmg783fv22i0arfgilsjvr";
  };
  nativeBuildInputs = [ cmake ];

  patchPhase = ''
    sed "s|DESTINATION include/| DESTINATION $out|g" -i CMakeLists.txt
  '';
}
