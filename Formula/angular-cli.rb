require "language/node"

class AngularCli < Formula
  desc "CLI tool for Angular"
  homepage "https://cli.angular.io/"
  url "https://registry.npmjs.org/@angular/cli/-/cli-8.3.22.tgz"
  sha256 "09fb5b8773e3faf7f39dec0292d1fe62f5801e8ced67d1400cb8f77fca883ff4"

  bottle do
    cellar :any_skip_relocation
    sha256 "c7d111dee949316115d79c9e16fda66a7d5f1fe31e01990aa4066b25f1a41a0f" => :catalina
    sha256 "5bf763eead2727bee1ca9e01c4abc8f5d6828a5ea68e7e394cc6193770f960de" => :mojave
    sha256 "74357fbc9bfef01f5b1607b70cf2a30e8ba63442fa540b8c1a2314f77dcf267e" => :high_sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"ng", "new", "angular-homebrew-test", "--skip-install"
    assert_predicate testpath/"angular-homebrew-test/package.json", :exist?, "Project was not created"
  end
end
