# OS X开启ssh
<h2>首先了解launchd</h2>
>launchd is a unified, open-source service management framework for starting,<!--more--> stopping and managing daemons, applications, processes, and scripts.
Written and designed by Dave Zarzycki at Apple, it was introduced with Mac OS X Tiger and is licensed under the Apache License.

<h2>启动sshd</h2>
<pre><code>launchctl load -w /System/Library/LaunchDaemons/ssh.plist
</pre></code>

<h2>查看是否启动</h2>
<pre><code>launchctl list | grep ssh</pre></code>

<h2>使用github的https提交项目时总是报403错误，所以改用ssh</h2>

详细步骤：<a title="github help" href="https://help.github.com/articles/generating-ssh-keys" target="_blank">https://help.github.com/articles/generating-ssh-keys</a>
<ol>
	<li>cd ~/.ssh</li>
	<li>备份已经存在的key</li>
	<li>创建新的key：ssh-keygen -t rsa -C "your_email@youremail.com"</li>
	<li>添加key到github。在github中Account Setting 中创建ssh keys，将.ssh文件夹下的id_rsa.pub文件中内容拷贝到github中。</li>
	<li>测试是否成功：ssh -T git@github.com</li>
</ol>

