RELEASE := novu
HELM_CHART_REPO := git@github.com:novuhq/community-k8s.git
HELM_CHART_REPO_GIT_CLONE_PATH := ./origin
HELM_CHART := ./origin/helm
TIMEOUT := 1200s
NAMESPACE := novu
CLUSTER := <YOUR CLUSTER NAME>

prepare:
	mkdir $(HELM_CHART_REPO_GIT_CLONE_PATH) || true
	cd $(HELM_CHART_REPO_GIT_CLONE_PATH) && (git clone $(HELM_CHART_REPO) . || git pull)
	# the Git repo and has a Chart.lock which doesn't work with a fresh helm dependency build so we remove it
	rm $(HELM_CHART)/Chart.lock || true
	helm dependency build $(HELM_CHART)

install:
	kubectl config use-context $(CLUSTER)
	kubectl config set-context --current --cluster=$(CLUSTER) --namespace=$(NAMESPACE)

	kubectl create ns $(NAMESPACE) || true

	helm upgrade --install $(RELEASE) $(HELM_CHART) --namespace $(NAMESPACE) --values ./values.yaml


purge:
	helm delete $(RELEASE) -n $(NAMESPACE)
