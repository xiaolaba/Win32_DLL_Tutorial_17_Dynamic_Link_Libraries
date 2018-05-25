Basic writing and formatting syntax https://help.github.com/articles/basic-writing-and-formatting-syntax/


# Win32_DLL_Tutorial_17_Dynamic_Link_Libraries
Win32 DLL, Tutorial 17: Dynamic Link Libraries, 
copy [Iczelion's Win32 Assembly Homepage]

翻譯然後讀書筆記


教程17：動態鏈接庫 (原文 http://win32assembly.programminghorizon.com/tut17.html)
在本教程中，我們將學習DLL，它們是什麼以及如何創建它們。
你可以在這裡下載這個例子。

理論：
如果你編程經驗足夠長，你會發現你寫的程序通常有一些代碼例程。 每當你開始編寫新程序時，重寫它們是浪費時間。 早在DOS時代，程序員就將這些常用的例程存儲在一個或多個庫中。 當他們想使用函數時，他們只需將庫鏈接到目標文件，鏈接器從庫中提取函數並將它們插入到最終的可執行文件中。 這個過程稱為靜態鏈接。 C運行時庫就是很好的例子。 這種方法的缺點是每個調用它們的程序都有相同的功能。 您的磁盤空間被浪費了，存儲了幾個相同的功能副本。 但是對於DOS程序運行，這種方法是完全可以接受的，因為通常只有一個程序在內存中處於活動狀態。 所以不會浪費寶貴的記憶體空間。

在Windows下，情況變得很不一樣，因為您可以同時運行多個程序。 如果程序非常大，內存會很快被吃光。 Windows有這種類型的問題的解決方案：動態鏈接庫 Dynamic Link Libraries (DLL)。 動態鏈接庫是一種常見的函數庫。 Windows不會將多個DLL副本加載到內存中，因此即使程序中有許多實例同時運行，也只會加載一個DLL副本在內存中供應用程序使用。 我應該澄清一點, 實際上, 所有使用相同dll的進程都會擁有自己的該dll副本, 同一個DLL會看起來像在內存中有許多副本。 但是實際上，Windows在分頁機制方面有著神奇的效果，所有進程都共享記憶體裡面相同的DLL代碼。因此，在物理內存中，只有一個DLL代碼副本。 但是，每個進程都將擁有其自己的唯一數據部分的DLL。該程序在運行時鏈接到一個DLL，與舊的靜態庫不同。 這就是為什麼它被稱為動態鏈接庫。 當你不需要它的時候，你也可以在運行時卸載一個DLL。 如果該程序是唯一使用DLL的程序，它將立即從內存中卸載。 但是，如果該DLL仍被其他程序使用，則該DLL將保留在內存中，直到使用其服務的最後一個程序將其卸載。

但是，要建立最終的可執行文件而必須執行地址修正時，鏈接器的工作更加困難。 由於它不能單純 “提取” 功能並簡單將它們插入到最終的可執行文件中，它必須以某種方式將關於DLL和函數的足夠信息存儲到最終的可執行文件中，以便它能夠在運行時找到並加載正確的DLL。這就需要 [導入庫] Import Library , 導入庫包含它所代表的DLL的信息。 鏈接器可以從導入庫中提取需要的信息並將其填充到可執行文件中。 當Windows加載程序將程序加載到內存中時，它會看到該程序鏈接到一個DLL，因此它會搜索該DLL並將其映射到該進程的地址空間中，並執行用於調用DLL中函數的地址修正。

您可以選擇自己加載DLL而不依賴Windows加載器, 使用 WIN32 的 LoadLibrary()。 這種方法有其優點和缺點：

* 它不需要導入庫，因此即使沒有導入庫，也可以加載和使用任何DLL。 但是，您仍然需要了解其中的功能，它們需要的參數以及類似參數。

* 當你讓加載程序加載你的程序的DLL時，如果加載程序找不到DLL，它會報告“一個必需的.DLL文件，xxxxx.dll丟失”！ 即使該DLL對其操作不重要，程序也沒有機會運行。 如果你自己加載DLL，當找不到DLL並且它不是操作必不可少的，你的程序可以告訴用戶這個事實並繼續。

* 您可以調用未包含在導入庫中的或未公開的函數。 只要你知道有關功能的足夠信息。

* 如果使用 LoadLibrary，則必須為每個要調用的函數調用 GetProcAddress。 GetProcAddress 檢索特定DLL中函數的入口點地址。 所以你的代碼可能會稍微大一些，開始的執行速度稍慢一點點而已。

看到 LoadLibrary 調用的優點/缺點，我們將詳細介紹如何創建一個DLL。
以下代碼最基本的是DLL源碼的骨架。供兩個檔案,


[code]
```
; assembler : MASM32 SDK Version 11
; date : 2018-MAY-25
; download : http://www.masm32.com/download.htm
; source code : http://win32assembly.programminghorizon.com/files/tut17.zip

;--------------------------------------------------------------------------------------
; DLLSkeleton.asm
;--------------------------------------------------------------------------------------
.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data
.code
DllEntry proc hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD
    mov eax,TRUE
    ret
DllEntry Endp
;---------------------------------------------------------------------------------------------------
; This is a dummy function
; It does nothing. I put it here to show where you can insert functions into
; a DLL.
;----------------------------------------------------------------------------------------------------
TestFunction proc
    ret
TestFunction endp

End DllEntry
```
[/code]

.

.


[code]
```
; assembler : MASM32 SDK Version 11
; date : 2018-MAY-25
; download : http://www.masm32.com/download.htm
; source code : http://win32assembly.programminghorizon.com/files/tut17.zip
;-------------------------------------------------------------------------------------
; DLLSkeleton.def
;-------------------------------------------------------------------------------------
LIBRARY DLLSkeleton
EXPORTS TestFunction
```
[/code]


以上兩個檔案就是一個最基本DLL骨架的源碼程序。 每個DLL必須有一個入口函數 (entrypoint function)。 Windows將每次調用入口函數：

1) 該DLL首次被加載到RAM
2) 該DLL被卸載
3) 一個線程在同一個進程中創建
4) 線程在同一個進程中被銷毀


[code]

DllEntry proc hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD
    mov eax,TRUE
    ret
DllEntry Endp

[/code]

分析參考以上源碼, 命名 <入口點函數名稱> 任意, 只要 proc / endp 兩行看到同樣的名稱.

DllEntry proc

DllEntry Endp

這個函數有三個參數，只有前兩個參數很重要。
1) hInstDLL是DLL的模塊句柄。 它與流程的實例句柄不一樣。 如果您以後需要使用它，您應該保留此值。 你不能輕易獲得它。
2) reason 用以下四個可選值之一：

* DLL_PROCESS_ATTACH當DLL首次被注入進程地址空間時，它會收到這個值。 你可以使用這個機會來進行初始化。
* DLL_PROCESS_DETACH當DLL從進程地址空間卸載時，它會收到這個值。 你可以使用這個機會來做一些清理，例如釋放內存等等。
* DLL_THREAD_ATTACH當進程創建一個新線程時，DLL接收到這個值。
* DLL_THREAD_DETACH當進程中的線程被銷毀時，DLL接收到這個值。


如果您希望DLL繼續運行，那麼您在eax中返回TRUE。 如果您返回FALSE，則不會加載該DLL。 例如，如果您的初始化代碼必須分配一些內存並且不能成功執行，則入口函數應返回FALSE以指示該DLL無法運行。
你可以把你的函數放入入口函數之後的DLL中或之前。 但是，如果您希望可以從其他程序調用它們，則必須將它們的名稱放在模塊定義文件（.def）的導出列表中。
一個DLL在其開發階段需要一個模塊定義文件。 我們現在來看看它。

[code]

LIBRARY DLLSkeleton
EXPORTS TestFunction

[/code]

必須有第一行 LIBRARY 語句定義了 DLL的內部模塊名稱。 您應該將它與DLL的文件名相匹配。
EXPORTS語句告訴鏈接器DLL中的哪些函數被導出，也就是說可以從其他程序中調用。 在這個例子中，我們希望其他模塊能夠調用 TestFunction，所以我們把它的名字放在EXPORTS語句中。
另一個需要注意是 Link 的選項。 必須有 /DLL / DEF：<您的def文件名> ，如下所示：

[code]

link /DLL /SUBSYSTEM:WINDOWS /DEF:DLLSkeleton.def /LIBPATH:c:\masm32\lib DLLSkeleton.obj

[/code]

assembler (ml.exe) 的選項則相同，即/ c / coff / Cp。 因此，在鏈接目標文件後，您將獲得 .dll 和. lib。 .lib是導入庫，您可以使用它導入使用DLL中功能的其他程序。

接下來，我將向您展示如何使用 LoadLibrary 加載 DLL。

[code]

; assembler : MASM32 SDK Version 11
; date : 2018-MAY-25
; download : http://www.masm32.com/download.htm
;---------------------------------------------------------------------------------------------
; UseDLL.asm
;----------------------------------------------------------------------------------------------
.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
LibName db "DLLSkeleton.dll",0
FunctionName db "TestHello",0
DllNotFound db "Cannot load library",0
AppName db "Load Library",0
FunctionNotFound db "TestHello function not found",0

.data?
hLib dd ? ; the handle of the library (DLL)
TestHelloAddr dd ? ; the address of the TestHello function

.code
start:
invoke LoadLibrary,addr LibName
;---------------------------------------------------------------------------------------------------------
; Call LoadLibrary with the name of the desired DLL. If the call is successful
; it will return the handle to the library (DLL). If not, it will return NULL
; You can pass the library handle to GetProcAddress or any function that requires
; a library handle as a parameter.
;------------------------------------------------------------------------------------------------------------
.if eax==NULL
invoke MessageBox,NULL,addr DllNotFound,addr AppName,MB_OK
.else
mov hLib,eax
invoke GetProcAddress,hLib,addr FunctionName
;-------------------------------------------------------------------------------------------------------------
; When you get the library handle, you pass it to GetProcAddress with the address
; of the name of the function in that DLL you want to call. It returns the address
; of the function if successful. Otherwise, it returns NULL
; Addresses of functions don't change unless you unload and reload the library.
; So you can put them in global variables for future use.
;-------------------------------------------------------------------------------------------------------------
.if eax==NULL
invoke MessageBox,NULL,addr FunctionNotFound,addr AppName,MB_OK
.else
mov TestHelloAddr,eax
call [TestHelloAddr]
;-------------------------------------------------------------------------------------------------------------
; Next, you can call the function with a simple call with the variable containing
; the address of the function as the operand.
;-------------------------------------------------------------------------------------------------------------
.endif
invoke FreeLibrary,hLib
;-------------------------------------------------------------------------------------------------------------
; When you don't need the library anymore, unload it with FreeLibrary.
;-------------------------------------------------------------------------------------------------------------
.endif
invoke ExitProcess,NULL
end start

[/code]


所以你可以看到使用LoadLibrary有一點涉及，但它也更靈活。
[ Iczelion的Win32程序集主頁 ]
