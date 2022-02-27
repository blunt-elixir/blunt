.SHELLFLAGS += -e

deps:
	cd ./apps/blunt && mix deps.get
	cd ./apps/blunt_ddd && mix deps.get
	cd ./apps/blunt_absinthe && mix deps.get
	cd ./apps/blunt_absinthe_relay && mix deps.get
	cd ./apps/blunt_toolkit && mix deps.get

blunt:
	cd ./apps/blunt && mix compile --force

ddd:
	cd ./apps/blunt_ddd && mix compile --force

absinthe:
	cd ./apps/blunt_absinthe && mix compile --force

absinthe_relay:
	cd ./apps/blunt_absinthe_relay &&  mix compile --force

toolkit:
	cd ./apps/blunt_toolkit && mix compile --force

all: absinthe_relay ddd

test_blunt: 
	cd ./apps/blunt && mix test

test_ddd: 
	cd ./apps/blunt_ddd && mix test

test_absinthe: 
	cd ./apps/blunt_absinthe && mix test

test_absinthe_relay:
	cd ./apps/blunt_absinthe_relay &&  mix test

test: test_blunt test_ddd test_absinthe test_absinthe_relay
