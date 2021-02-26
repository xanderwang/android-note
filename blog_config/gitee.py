import os
from subprocess import call

GITEE_NAME = os.environ["GITEE_NAME"]
GITEE_EMAIL = os.environ["GITEE_EMAIL"]
GITEE_PATH = os.environ["GITEE_PATH"]

print("GITEE_NAME:", GITEE_NAME, ",GITEE_EMAIL:", GITEE_EMAIL)
print("GITEE_PATH:", GITEE_PATH)


def doGit(git_cmd):
    print(git_cmd)
    call(git_cmd)


# 设置邮箱等配置
cmd_list = [
    "git config --local user.name \"{0}\"".format("420640763@qq.com"),
    "git config --local user.email \"{0}\"".format("XanderWang"),
    "git remote rm origin",
    "git remote add origin {0}".format(GITEE_PATH),
    "git config --list",
    "git add ./",
    "git commit -m \"auto build task\"",
]

try :
    for cmd in cmd_list:
        doGit(cmd)
except Exception as e:
    print(e)

