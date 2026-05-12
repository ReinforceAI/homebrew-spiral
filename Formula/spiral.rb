class Spiral < Formula
  desc "Calibration-free transformer compression for Qwen on Mac and CUDA"
  homepage "https://github.com/ReinforceAI/spiral"
  url "https://github.com/ReinforceAI/spiral/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "5de985fcb313d4e4c25dfc2220dff0500ad4d128d99407342545537539a6dbdc"
  license "MIT"

  depends_on "cmake" => :build
  depends_on :macos

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DGGML_METAL=ON",
           "-DLLAMA_CURL=OFF",
           "-DBUILD_SHARED_LIBS=ON",
           *std_cmake_args
    system "cmake", "--build", "build", "--config", "Release"

    # All dylibs are built into build/bin/ alongside the executables
    bin.install "build/bin/llama-cli"
    bin.install "build/bin/llama-server"
    bin.install "build/bin/llama-simple"

    # Install shared libraries from build/bin/
    lib.install Dir["build/bin/lib*.dylib"]

    # Fix rpaths so binaries find the libs
    %w[llama-cli llama-server llama-simple].each do |b|
      system "install_name_tool", "-add_rpath", lib.to_s, bin/b
    end

    # Install Spiral wrapper scripts
    bin.install "bin/spiral-chat"
    bin.install "bin/spiral-serve"
    bin.install "bin/spiral-download"
  end

  def post_install
    (var/"spiral/models").mkpath
  end

  def caveats
    <<~EOS
      Spiral v0.3.0 installed. Available models:

        qwen-25-7b-spiral     Qwen2.5-Coder-7B   (3.0 GB,  v0.2.0 Spiral_3)
        qwen-36-35b-spiral    Qwen3.6-35B-A3B    (20 GB,  v0.3.0 Spiral_4_5)

      On first run, the selected model downloads automatically to
      ~/.spiral/models/

      Quick start:
        spiral-chat                                    # 7B interactive (default)
        spiral-chat --model qwen-36-35b-spiral         # 35B interactive
        spiral-serve --model qwen-36-35b-spiral        # API server on port 8080
        spiral-chat --prompt "hello" --greedy          # single prompt

      For more info: spiral-chat --help
    EOS
  end

  test do
    assert_match "spiral", shell_output("#{bin}/spiral-chat --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-serve --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-download --help 2>&1")
  end
end