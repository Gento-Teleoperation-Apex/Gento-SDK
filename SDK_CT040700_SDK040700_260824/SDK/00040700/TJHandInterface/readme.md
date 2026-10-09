

build_windows_example_exe.bat 用于生成可执行文件
build_windows_dll.bat 用于生成动态库gento，包含灵巧手

----------------------------------------------------------------------------------------------------
更新说明（脚本已支持免移动文件编译）：
  · win_auto_compile.bat / linux_auto_compile.sh：
      编译libGentoSDK.dll/.so和libGentoSDKPY.dll/.so时，自动追加本文件夹下的TJHand.cpp，
      并包含本文件夹下的TJ_HAND_1\include；编译后自动将库分发到PYTHON_SDK\和
      C_EXAMPLE_USE_DLL_SO\（与原逻辑一致）。
  · build_windows.bat / build_linux.sh：
      源码方式编译示例程序，同样自动追加TJHand.cpp并链接TJ_HAND_1\lib\libTJHandLogic.a；
      TJ_HAND_1路径已从"..\TJ_HAND_1"改为本文件夹下的"TJ_HAND_1"，与目录结构一致。
  · 由于上述改动，原第1、2步的手工文件拷贝不再需要，脚本放在TJHandInterface文件夹内
      原地运行即可完成含灵巧手接口的Gento库编译。
  · 第6条的兼容性保持不变：TJ_HAND_1文件夹或TJHand.cpp不存在时，脚本自动退化为
      不带灵巧手功能的普通编译。

----------------------------------------------------------------------------------------------------
1、将TJ_HAND_1文件夹放至与C_SDK相同目录下；
   【已自动处理】编译脚本现直接从本文件夹（TJHandInterface）定位TJ_HAND_1，无需拷贝；
2、将TJHand.h和TJHand.cpp文件放至\C_SDK\L1Robot目录下；
   【已自动处理】编译脚本已将本文件夹下的TJHand.cpp追加到SDK源码一起编译，
   TJHand.h位于本文件夹下，无需拷贝到L1Robot目录；
3、用文件夹中的脚本取代原来的脚本去编译sdk库及应用程序；
4、用GentoRobot.py取代原来目录下相同文件；
5、example_basic_hand.cpp和example_basic_TJ_Hand.py分别为C和PYTHON的示例程序；
6、若一代手相关文件不存在【指TJ_HAND_1文件夹、TJHand.h和TJHand.cpp文件】，使用新的编译脚本不影响原来代码的编译；
7、用户在使用时，只需要链接新生成的libGento库即可，不需要添加TJ_HAND_1的库；
8、TJHand.h为用户需要查看的接口文件。


