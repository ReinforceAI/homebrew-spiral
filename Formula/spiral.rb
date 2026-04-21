class Spiral < Formula
  desc "Run 7B coding models on Mac with 200K+ token context via physics-derived compression"
  homepage "https://github.com/reinforceai/spiral"
  url "https://github.com/ReinforceAI/spiral/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  depends_on "cmake" => :build
  depends_on :macos

  def install
    # Build llama.cpp with Spiral extensions
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DGGML_METAL=ON",
           "-DLLAMA_CURL=OFF",
           *std_cmake_args
    system "cmake", "--build", "build", "--config", "Release"

    # Install llama binaries
    bin.install "build/bin/llama-cli"
    bin.install "build/bin/llama-server"
    bin.install "build/bin/llama-simple"

    # Install Spiral wrapper scripts
    bin.install "bin/spiral-chat"
    bin.install "bin/spiral-serve"
    bin.install "bin/spiral-download"
  end

  def post_install
    # Create model directory
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