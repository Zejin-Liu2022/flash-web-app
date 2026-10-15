# Flask Web App · 头歌自动化部署

课程实验用 Flask 项目，监听 0.0.0.0:5000，由 Supervisor 管理。

## 本地运行与测试

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
python -m pytest tests/ -v
python -m src.app
```

## 自动化部署

推送到 main 后，GitHub Actions 在 Python 3.11 中测试，通过后通过 SSH 端口 47263 部署同一提交。PR 仅测试。也支持手动运行工作流。

仓库 Settings → Secrets and variables → Actions 需要：

- TOUGE_SERVER_IP：服务器 IP。
- TOUGE_SSH_PRIVATE_KEY：本项目专用私钥完整内容。
- TOUGE_SSH_KNOWN_HOSTS：已验证的服务器主机公钥记录（含端口）。

服务器项目路径：/root/flask-web-app；Python 环境：.venv；进程名：flask-web-app。

```sh
supervisorctl status flask-web-app
supervisorctl restart flask-web-app
tail -n 50 /var/log/flask-web-app.log
```

头歌服务预览添加内部端口 5000，再打开 Web 预览。47263 是 SSH 端口。实验环境重置后需重新准备服务器；IP 或 SSH 端口变化后更新配置。

密码和私钥不得提交到仓库。依赖隔离安装遵循 Flask 官方建议：https://flask.palletsprojects.com/en/stable/installation/
