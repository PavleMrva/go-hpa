deploy:
	kubectl apply -f k8s.yml
autoscale:
	kubectl autoscale deployment go-hpa --cpu-percent=20 --min=1 --max=5
get-hpa:
	kubectl get hpa
increase-load:
	kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://go-hpa:8080; done"
cleanup:
	kubectl delete -f k8s.yml && \
	kubectl delete pod load-generator && \
	kubectl delete hpa go-hpa

