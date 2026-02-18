# git设置

## 设置git的用户名和邮箱

git config --global user.name "watice"
git config --global user.email "w1825692103@gmail.com"

## 设置git代理

git config --global http.proxy http://127.0.0.1:7890
> 此为clash代理端口

# vs code 配置

```json
// 让预览时单个换行生效
"markdown.preview.breaks": true,
// 自动保存
"files.autoSave": "afterDelay",
"files.autoSaveDelay": 1000,
// 编辑器优化
"editor.wordWrap": "on",
"editor.fontSize": 16,
"editor.lineHeight": 1.8,


# markdown基础语法

# 一级标题
## 二级标题

*斜体* 或 _斜体_
**粗体** 或 __粗体__
***粗斜体*** 或 ___粗斜体___
~~删除线~~
==高亮==

> 无序列表
- 项目1
- 项目2
  - 子项目2.1
  - 子项目2.2
* 也可以用星号
+ 或者加号

> 有序列表
> 
1. 第一项
2. 第二项
   1. 子项2.1
   2. 子项2.2
3. 第三项

> 链接和图片

// 普通链接
[链接文字](https://example.com)

// 带标题的链接
[链接文字](https://example.com "鼠标悬停提示")

// 图片
![替代文字](图片地址)

// 带标题的图片
![替代文字](图片地址 "图片标题")

> 这是一级引用
>> 这是二级引用
>>> 这是三级引用

> 行内代码
>
> 
使用 `printf()` 函数打印

> 代码块
```语言名称
// 代码内容
function hello() {
    console.log("Hello World");
}


