PX_KILLER_IMG=harshpx/px-killer:latest

all: clean
	go build -o px-killer kill-px.go

	@echo "Building container: docker build --tag $(PX_KILLER_IMG) -f Dockerfile ."
	sudo docker build --tag $(PX_KILLER_IMG) -f Dockerfile .

deploy: all
	docker push $(PX_KILLER_IMG)

clean:
	-rm -rf px-killer
	-docker rmi -f $(PX_KILLER_IMG)
