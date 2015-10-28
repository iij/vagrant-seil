# IIJ SEIL/x86 のための Vagrant プラグイン

Vagrant に SEIL/x86 のサポートを追加するプラグインです。
Vagrant を使って SEIL/x86 のインスタンスを操作したり設定を投入できます。

このプラグインを利用するためには *Vagrant 1.7 以降が必要です。*


## 機能
- SEIL/x86 を起動/停止できます。
- ライセンスキーを自動で入力できます。
- 専用のプロバイダを利用して設定を投入できます。
- Private/Public ネットワークを利用可能です。


## 使い方

通常の Vagrant プラグイン導入方法にしたがってインストールしてください。

```
$ vagrant plugin install vagrant-seil
```

## 試してみる

Vagrant 上で SEIL/x86 を起動するためには三つのファイルが必要になります。

- SEIL/x86 の Vagrant box イメージ
- 起動キー
- 機能キー

SEIL/x86 の Vagrant box イメージは [SEIL/x86 ダウンロードサイト](https://www.seil.jp/seilx86_download/) から入手できます。「起動キー」も同サイトから入手してください。「機能キー」は [LaIT販売サイト](https://la-it.jp/supply/item_list/seilx86.html) から購入するか、または [アカデミックライセンス](http://www.seil.jp/download/seil-x86/academic-licence/) を取得してください。

まずは Vagrant box イメージを適当な名前で追加します。

```
% vagrant box add --name seil ./seilx86-500.box
```

最小限の Vagrantfile は以下のようになります。「起動キー」を "starterkey.txt"、「機能キー」を "functionkey.txt" という名前でカレントディレクトリに置いておいてください。

```
Vagrant.configure("2") do |config|
  config.vm.box = "seil"
  config.vm.provision :seil do |seil|
    seil.starter_key  = File.read("starterkey.txt")
    seil.function_key = File.read("functionkey.txt")
  end
end
```

``vagrant up`` を実行すると SEIL/x86 が起動します。


## 設定

プラグイン固有の設定項目は以下の通りです:

- ``starter_key`` - 「起動キー」を指定します。
- ``function_key`` - 「機能キー」を指定します。
- ``config`` - インスタンスの SEIL/x86 のコンフィグを指定します。

なおホスト OS からの制御のため、以下のコンフィグが固定的に設定されます。これらの設定を変更するとホストから制御できなくなる場合があるため、変更しないようにしてください。

```
interface lan0 add dhcp
sshd authorized-key admin add vagrant ...
sshd enable
```

## ネットワーク

``forwarded_port``, ``private_network``, ``public_network`` いずれの設定にも対応しています。ただし、LAN0 にホスト OS との通信用の DHCP クライアントが固定的に設定されるため、`type: "dhcp"` 設定は利用できません。



## ライセンス
Copyright (c) 2015 Internet Initiative Japan Inc.

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.


*一部のコード(VagrantPlugins::Seil::Communicator#shell_execute)は以下の条件に従って配布されています:*

The MIT License

Copyright (c) 2010-2015 Mitchell Hashimoto

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
