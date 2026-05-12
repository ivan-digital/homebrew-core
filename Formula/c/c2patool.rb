class C2patool < Formula
  desc "CLI for working with C2PA manifests and media assets"
  homepage "https://contentauthenticity.org"
  url "https://github.com/contentauth/c2pa-rs/archive/refs/tags/c2patool-v0.26.57.tar.gz"
  sha256 "e42e2b04b94333c8f8429b924061459b8e60230b385ff34d7b49eff2a5bc488f"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/contentauth/c2pa-rs.git", branch: "main"

  livecheck do
    url :stable
    regex(/^c2patool[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "b674ed980946672285c10bf5ac044d7a0774621e1281f2b191d14444b89f71f1"
    sha256 cellar: :any,                 arm64_sequoia: "c31d61265c9a0b54138a3e174a0385fb08e1812516c1831f61ca6dcf9687f354"
    sha256 cellar: :any,                 arm64_sonoma:  "98a56959c0f335f280b8a944eaaa455e32f1938ba7ef2a525fdd10728d424a8e"
    sha256 cellar: :any,                 sonoma:        "752c261810b4b663dee6d7c8d2dd9d129faf922d74a080ecace58ee29a833178"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "bcc10415a82874866b27b832c40197aac8cd04f6ba340c562ea58d268ce7ca1f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ae70d5fa8acc798bcc839b9cf81e9f340da7c3b5c9caaaa0d3dbb8d5668af478"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  def install
    ENV["OPENSSL_DIR"] = Formula["openssl@4"].opt_prefix
    system "cargo", "install", *std_cargo_args(path: "cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/c2patool -V").strip

    (testpath/"test.json").write <<~JSON
      {
        "assertions": [
          {
            "label": "com.example.test",
            "data": {
              "my_key": "my_value"
            }
          }
        ]
      }
    JSON

    system bin/"c2patool", test_fixtures("test.png"), "-m", "test.json", "-o", "signed.png", "--force"

    output = shell_output("#{bin}/c2patool signed.png")
    assert_match "\"issuer\": \"C2PA Test Signing Cert\"", output
  end
end
