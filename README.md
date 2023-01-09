# helm-charts-practice

本リポジトリは、ArgoCDを使用してチャートをデプロイし、チャートの技術を学習するリポジトリです。

ついでに、ディレクトリの構成方法も学習します。

# セットアップ

## Minikube

Minikubeを起動する。

```bash
$ minikube start --memory 8192 --cpus 8 --nodes 2
```

## ArgoCD

### デプロイ

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd.yaml diff
$ helmfile -e dev -f helmfile.d/argocd.yaml apply
```

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml diff
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml apply
```

### ダッシュボードへのアクセス

dev環境では、追加で作成しているNodePort Serviceを介して、ArgoCDのダッシュボードに接続する。

返却されるURLにアクセスする。

```bash
$ minikube service argocd-server --url -n argocd
```
