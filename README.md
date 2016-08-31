## 大致功能
* 查看目录树及文件内容
* 修改文件内容并提交
* git log
* git diff

## 运行方式
1. 把 git 裸仓库(bare repository) 放到本项目的 `repos` 文件夹下
2. `bundle install`
3. `rails server`

## 关于 bare repository
可以使用
```shell
git clone --bare <GIT_REPO_OR_PATH>
```
得到一个 git 仓库的裸仓库
