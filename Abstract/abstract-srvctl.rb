require 'formula'

class AbstractSrvctl < Formula
  def self.init
    homepage 'https://github.com/serverscom/srvctl'
    head 'https://github.com/serverscom/srvctl.git'

    test do
      system "#{bin}/srvctl", '--version'
    end

    on_macos do
      on_arm do
        url "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl_#{version}_darwin_arm64.zip"
        sha256 checksums.fetch('darwin_arm64')
      end
      on_intel do
        url "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl_#{version}_darwin_amd64.zip"
        sha256 checksums.fetch('darwin_amd64')
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl_#{version}_linux_arm64.zip"
        sha256 checksums.fetch('linux_arm64')
      end
      on_intel do
        url "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl_#{version}_linux_amd64.zip"
        sha256 checksums.fetch('linux_amd64')
      end
    end
  end

  def install
    bin.install 'srvctl'

    # Скачиваем и устанавливаем man-страницы
    docs_url = "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl-docs-generated_#{version}.zip"
    system 'curl', '-sL', docs_url, '-o', 'docs.zip'
    system 'unzip', '-q', 'docs.zip'
    man1.install Dir['docs/generated/man/*.1']
  end

  def self.checksums
    @checksums ||= fetch_checksums
  end

  def self.fetch_checksums
    require 'net/http'
    checksums_url = "https://github.com/serverscom/srvctl/releases/download/v#{version}/srvctl_#{version}_SHA256SUMS"
    fetch(checksums_url).split("\n").each_with_object({}) do |line, h|
      sha, file = line.split(' ')
      platform = file.gsub("srvctl_#{version}_", '').split('.').first
      h[platform] = sha
    end
  end

  def self.fetch(url, redirects = 5)
    require 'net/http'
    raise 'Too many redirects' if redirects.zero?

    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.get(uri)
    end

    return fetch(response['location'], redirects - 1) if response.is_a?(Net::HTTPRedirection)
    return response.body if response.is_a?(Net::HTTPSuccess)

    raise "Failed to fetch checksums.txt from #{uri}: #{response.code} #{response.message}"
  end
end
