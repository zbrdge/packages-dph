DPHDIR = $(TOPDIR)/..

HC = $(DPHDIR)/../../ghc/stage2-inplace/ghc
HCPKG = $(DPHDIR)/../../utils/ghc-pkg/install-inplace/bin/ghc-pkg

BENCH_DIR = $(TOPDIR)/lib
BENCH_FLAGS = -package dph-bench -package-conf $(BENCH_DIR)/dph-bench.conf
BENCH_DEP = $(BENCH_DIR)/dist/inplace-pkg-config

DPH_FLAGS = -Odph -funbox-strict-fields -fcpr-off -threaded

WAYS = seq par
WAY_FLAGS = -fdph-$(WAY) -package dph-$(WAY) -odir $(WAY) -hidir $(WAY)

CFLAGS = -O6