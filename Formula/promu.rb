class Promu < Formula
  desc "Prometheus Utility Tool"
  homepage "https://github.com/prometheus/promu#readme"
  # NOTE: not totally sure we can't use tarball
  url "https://github.com/prometheus/promu.git",
      tag:      "v0.7.0",
      revision: "b17dc4f71c810678db907367b392a3e7a14c4038"
  license "Apache-2.0"

  depends_on "go"

  # NOTE: probably should just be a (discarded?) resource in Prometheus formula

  def install
    # NOTE: sorta reverse engineering:
    #       - <https://github.com/prometheus/promu/blob/v0.7.0/Makefile>
    #       - <https://github.com/prometheus/promu/blob/v0.7.0/.promu.yml>
    # TODO: better way to DRY out the mentions of the revision?
    # TODO: look into ...version.Branch
    ldflags = %W[
      -s
      -X github.com/prometheus/common/version.Version=#{version}
      -X github.com/prometheus/common/version.Revision=b17dc4f71c810678db907367b392a3e7a14c4038
      -X github.com/prometheus/common/version.Branch=HEAD
      -X github.com/prometheus/common/version.BuildDate=#{DateTime.now.strftime("%Y%m%d-%H:%M:%S")}
    ].join(" ")
    system "go", "build", *std_go_args, "-ldflags", ldflags

    # de facto `make installcheck`
    system bin/"promu", "version"
    system bin/"promu", "info"
    system bin/"promu", "build", "--verbose"
  end

  test do
    (testpath/".promu.yml").write <<~'EOS'
      go:
          # Whenever the Go version is updated here, .travis.yml and
          # .circle/config.yml should also be updated.
          version: 1.15
      repository:
          path: github.com/prometheus/promu
      build:
          flags: -mod=vendor -a -tags 'netgo static_build'
          ldflags: |
              -s
              -X github.com/prometheus/common/version.Version={{.Version}}
              -X github.com/prometheus/common/version.Revision={{.Revision}}
              -X github.com/prometheus/common/version.Branch={{.Branch}}
              -X github.com/prometheus/common/version.BuildUser={{user}}@{{host}}
              -X github.com/prometheus/common/version.BuildDate={{date "20060102-15:04:05"}}
      tarball:
          files:
              - LICENSE
              - NOTICE
    EOS
    system bin/"promu", "version"
    system bin/"promu", "info"
  end
end
