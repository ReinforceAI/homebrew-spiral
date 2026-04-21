class Spiral < Formula
  desc "Run 7B coding models on Mac with 200K+ token context via physics-derived compression"
  homepage "https://github.com/ReinforceAI/spiral"
  url "https://github.com/ReinforceAI/spiral/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "dff6b49f8b1042a09c02dfb03c68f8f9ee7f18ca45eadbc4add44ad8244df4b0"
  license "MIT"

  depends_on "cmake" => :build
  depends_on :macos

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DGGML_METAL=ON",
           "-DLLAMA_CURL=OFF",
           "-DCMAKE_INSTALL_RPATH=#{lib}",
           "-DBUILD_SHARED_LIBS=ON",
           *std_cmake_args
    system "cmake", "--build", "build", "--config", "Release"
    system "cmake", "--install", "build"

    bin.install "bin/spiral-chat"
    bin.install "bin/spiral-serve"
    bin.install "bin/spiral-download"
  end

  def post_install
    (var/"spiral/models").mkpath
  end

  def caveats
    <<~EOS
      Spiral has been installed. On first run, the model will be
      downloaded automatically (~4.7 GB).

      Quick start:
        spiral-chat                     # interactive chat
        spiral-serve                    # API server on port 8080
        spiral-chat --prompt "hello"    # single prompt

      Models are stored in ~/.spiral/models/

      For more info: spiral-chat --help
    EOS
  end

  test do
    assert_match "spiral", shell_output("#{bin}/spiral-chat --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-serve --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-download --help 2>&1")
  end
end