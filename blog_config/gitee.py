import os
from subprocess import call

GITEE_NAME = os.environ["GITEE_NAME"]
GITEE_EMAIL = os.environ["GITEE_EMAIL"]
GITEE_PATH = os.environ["GITEE_PATH"]

print("GITEE_NAME:", GITEE_NAME, ",GITEE_EMAIL:", GITEE_EMAIL)
print("GITEE_PATH:", GITEE_PATH)

# 设置邮箱等配置
cmd_list = [
    "git config --local user.name " + GITEE_NAME,
    "git config --local user.email " + GITEE_EMAIL,
    "git config --list"
]

for cmd in cmd_list:
    call(cmd)

