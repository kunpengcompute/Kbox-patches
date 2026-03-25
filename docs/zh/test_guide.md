# 验收测试指南<a name="ZH-CN_TOPIC_0000002552663615"></a>

## 1 概述<a name="ZH-CN_TOPIC_0000002518186314"></a>

### 1.1 验收依据<a name="ZH-CN_TOPIC_0000002549706091"></a>

本手册是云手机产品验收的指导文档，在进行验收前请确保使用的物理环境、系统环境以及软件版本正确，本手册中的用例为云手机产品测试团队设计，覆盖Kbox云手机产品的基本功能。

### 1.2 注意事项<a name="ZH-CN_TOPIC_0000002549826087"></a>

1. 在进行验收前请确保使用的物理环境、系统环境以及软件版本正确并配套。
2. 执行验收用例前请首先完成Kbox云手机端到端环境部署，具体部署步骤请参见《[install_guide](install_guide.md)》。
3. 验收的项目应经过华为公司和用户双方相关人员的确认。
4. 在验收和初验测试过程中，双方人员应对照相关标准严格测试。由于部分指标参数出厂时已经测试，验收时限于条件可以进行抽测或免测。

>![](public_sys-resources/icon-note.gif) **说明：** 
>在实际验收测试过程中，以合同要求及双方约定为准进行验收，本手册仅供参考。

## 2 测试准备<a name="ZH-CN_TOPIC_0000002518186316"></a>

服务器硬件以及软件包信息、用例验收前环境部署以及密度测试方法等信息请参见《[install_guide](install_guide.md)》，BIOS/iBMC/CPLD版本请参见《[release_notes](release_notes.md)》。

## 3 测试约定<a name="ZH-CN_TOPIC_0000002549706087"></a>

**结果描述<a name="section62693428"></a>**

本文档约定使用如下的测试结果描述。

- PASS：按照用例的预置条件和测试步骤，测试结果与预期结果完全符合。
- FAIL：按照用例的预置条件和测试步骤，测试结果与预期结果不符合。
- NT：由于需求变更或测试环境原因，用例未执行测试。

## 4 测试用例及测试记录<a name="ZH-CN_TOPIC_0000002518346236"></a>

### 4.1 基本功能测试<a name="ZH-CN_TOPIC_0000002518186318"></a>

#### 4.1.1 创建Kbox云手机容器<a name="ZH-CN_TOPIC_0000002549826089"></a>

<a name="table27768935"></a>
<table><tbody><tr id="row1988636"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p26861861"><a name="p26861861"></a><a name="p26861861"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p28327138"><a name="p28327138"></a><a name="p28327138"></a>4.1.1</p>
</td>
</tr>
<tr id="row53617656"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p48062879"><a name="p48062879"></a><a name="p48062879"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p779118"><a name="p779118"></a><a name="p779118"></a>创建<term id="term1935813311278"><a name="term1935813311278"></a><a name="term1935813311278"></a>Kbox云手机容器</term>。</p>
</td>
</tr>
<tr id="row7012069"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p31106692"><a name="p31106692"></a><a name="p31106692"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p36614112"><a name="p36614112"></a><a name="p36614112"></a>无</p>
</td>
</tr>
<tr id="row61091552"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p49468641"><a name="p49468641"></a><a name="p49468641"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><p id="p83401348134316"><a name="p83401348134316"></a><a name="p83401348134316"></a>Kbox云手机基本环境已部署完成。</p>
</td>
</tr>
<tr id="row26284107"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p48637933"><a name="p48637933"></a><a name="p48637933"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol47358524"></a><a name="ol47358524"></a><ol id="ol47358524"><li>执行创建Kbox云手机容器命令<strong id="b19434195834313"><a name="b19434195834313"></a><a name="b19434195834313"></a>./android11_kbox.sh start kbox_image:tag <em id="i164346583438"><a name="i164346583438"></a><a name="i164346583438"></a>x y</em></strong>。<div class="note" id="note941455894317"><a name="note941455894317"></a><a name="note941455894317"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p2414558144313"><a name="p2414558144313"></a><a name="p2414558144313"></a>其中<em id="i5762647144417"><a name="i5762647144417"></a><a name="i5762647144417"></a>x，y</em>表示想要创建的容器编号首尾值，如创建1到9号容器则<strong id="b75402279486"><a name="b75402279486"></a><a name="b75402279486"></a><em id="i351184894811"><a name="i351184894811"></a><a name="i351184894811"></a>x</em></strong>输入1，<strong id="b114789348488"><a name="b114789348488"></a><a name="b114789348488"></a><em id="i481820509485"><a name="i481820509485"></a><a name="i481820509485"></a>y</em></strong>输入9；如果只想创建单个容器，仅输入<em id="i1876205710272"><a name="i1876205710272"></a><a name="i1876205710272"></a>x</em>即可。</p>
</div></div>
</li><li>执行命令<strong id="b107561812154112"><a name="b107561812154112"></a><a name="b107561812154112"></a>docker ps -a</strong>查看已创建成功的Kbox云手机容器及状态。</li></ol>
</td>
</tr>
<tr id="row47146745"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p60789982"><a name="p60789982"></a><a name="p60789982"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol25041524"></a><a name="ol25041524"></a><ol id="ol25041524"><li>Kbox云手机容器创建结束回显成功标志。</li><li>执行命令可以查询到已创建的设备及状态。</li></ol>
</td>
</tr>
<tr id="row1660410"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p275553"><a name="p275553"></a><a name="p275553"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row66660433"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p30785969"><a name="p30785969"></a><a name="p30785969"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.2 重启Kbox云手机容器<a name="ZH-CN_TOPIC_0000002549706089"></a>

<a name="table26778736"></a>
<table><tbody><tr id="row63739165"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p62598754"><a name="p62598754"></a><a name="p62598754"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p37334299"><a name="p37334299"></a><a name="p37334299"></a>4.1.2</p>
</td>
</tr>
<tr id="row464375"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p37614394"><a name="p37614394"></a><a name="p37614394"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p26867045"><a name="p26867045"></a><a name="p26867045"></a>重启Kbox云手机容器。</p>
</td>
</tr>
<tr id="row40476817"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p57396781"><a name="p57396781"></a><a name="p57396781"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p18627652"><a name="p18627652"></a><a name="p18627652"></a>无</p>
</td>
</tr>
<tr id="row33431146"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p23568328"><a name="p23568328"></a><a name="p23568328"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol29986390"></a><a name="ol29986390"></a><ol id="ol29986390"><li>Kbox云手机基本环境已部署完成。</li><li>Kbox云手机容器已启动。</li></ol>
</td>
</tr>
<tr id="row49697568"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p66080062"><a name="p66080062"></a><a name="p66080062"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol50884809"></a><a name="ol50884809"></a><ol id="ol50884809"><li>执行<strong id="b77811114432"><a name="b77811114432"></a><a name="b77811114432"></a>./android11_kbox.sh restart <em id="i982613377278"><a name="i982613377278"></a><a name="i982613377278"></a>x</em></strong>重启已启动的Kbox云手机容器。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i14403205314419"><a name="i14403205314419"></a><a name="i14403205314419"></a>x</em>表示容器编号数字部分。</p>
</div></div>
</li><li>执行<strong id="b1855792117436"><a name="b1855792117436"></a><a name="b1855792117436"></a>docker ps -a</strong>查看已重启成功的Kbox云手机容器及状态。</li></ol>
</td>
</tr>
<tr id="row31929956"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p36189605"><a name="p36189605"></a><a name="p36189605"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol45676887"></a><a name="ol45676887"></a><ol id="ol45676887"><li>Kbox云手机容器重启结束回显成功标志。</li><li>执行命令可以查询到已重启的设备及状态。</li></ol>
</td>
</tr>
<tr id="row12454319"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p2166929"><a name="p2166929"></a><a name="p2166929"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row36187939"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p45541984"><a name="p45541984"></a><a name="p45541984"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.3 删除Kbox云手机容器<a name="ZH-CN_TOPIC_0000002518346234"></a>

<a name="table24712267"></a>
<table><tbody><tr id="row43575614"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p39963839"><a name="p39963839"></a><a name="p39963839"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p15845492"><a name="p15845492"></a><a name="p15845492"></a>4.1.3</p>
</td>
</tr>
<tr id="row8391701"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p8639220"><a name="p8639220"></a><a name="p8639220"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p28688252"><a name="p28688252"></a><a name="p28688252"></a>删除Kbox云手机容器。</p>
</td>
</tr>
<tr id="row56867678"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p42879221"><a name="p42879221"></a><a name="p42879221"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p50664905"><a name="p50664905"></a><a name="p50664905"></a>无</p>
</td>
</tr>
<tr id="row53330965"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p24840910"><a name="p24840910"></a><a name="p24840910"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol65956728"></a><a name="ol65956728"></a><ol id="ol65956728"><li>Kbox云手机基本环境已部署完成。</li><li>Kbox云手机容器已启动。</li></ol>
</td>
</tr>
<tr id="row32508693"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p15958447"><a name="p15958447"></a><a name="p15958447"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol17565813"></a><a name="ol17565813"></a><ol id="ol17565813"><li>执行<strong id="b136041379487"><a name="b136041379487"></a><a name="b136041379487"></a>./android11_kbox.sh delete <em id="i153381530142713"><a name="i153381530142713"></a><a name="i153381530142713"></a>x</em></strong>删除Kbox云手机容器。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i910185817441"><a name="i910185817441"></a><a name="i910185817441"></a>x</em>表示容器编号数字部分。</p>
</div></div>
</li><li>执行<strong id="b57619016493"><a name="b57619016493"></a><a name="b57619016493"></a>docker ps -a</strong>查看当前环境上的Kbox云手机容器。</li></ol>
</td>
</tr>
<tr id="row54794201"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p9145326"><a name="p9145326"></a><a name="p9145326"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol2573964"></a><a name="ol2573964"></a><ol id="ol2573964"><li>Kbox云手机容器删除结束显示成功标志。</li><li>执行命令查看到的Kbox云手机容器列表中没有已被删除的Kbox云手机容器。</li></ol>
</td>
</tr>
<tr id="row7164506"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p43454080"><a name="p43454080"></a><a name="p43454080"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row2640866"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p12583597"><a name="p12583597"></a><a name="p12583597"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.4 Kbox云手机容器状态查询<a name="ZH-CN_TOPIC_0000002549826077"></a>

<a name="table35101782"></a>
<table><tbody><tr id="row13303384"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p3832334"><a name="p3832334"></a><a name="p3832334"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p41983644"><a name="p41983644"></a><a name="p41983644"></a>4.1.4</p>
</td>
</tr>
<tr id="row42308484"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p4435211"><a name="p4435211"></a><a name="p4435211"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p23707773"><a name="p23707773"></a><a name="p23707773"></a>查询Kbox云手机容器状态。</p>
</td>
</tr>
<tr id="row12043371"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p35988971"><a name="p35988971"></a><a name="p35988971"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p29425548"><a name="p29425548"></a><a name="p29425548"></a>无</p>
</td>
</tr>
<tr id="row63503344"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p43497253"><a name="p43497253"></a><a name="p43497253"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol33616590"></a><a name="ol33616590"></a><ol id="ol33616590"><li>Kbox云手机基本环境已部署完成。</li><li>Kbox云手机容器已启动。</li></ol>
</td>
</tr>
<tr id="row11759093"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p12962448"><a name="p12962448"></a><a name="p12962448"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol43325372"></a><a name="ol43325372"></a><ol id="ol43325372"><li>执行<strong id="b23391240113719"><a name="b23391240113719"></a><a name="b23391240113719"></a>docker ps -a</strong>查看当前环境上的Kbox云手机容器。</li><li>执行<strong id="b74511540378"><a name="b74511540378"></a><a name="b74511540378"></a>docker exec -it kbox_<em id="i12466815192718"><a name="i12466815192718"></a><a name="i12466815192718"></a>x</em> sh</strong>进入Kbox云手机容器后执行<strong id="b6763205173812"><a name="b6763205173812"></a><a name="b6763205173812"></a>getprop | grep sys.boot_completed</strong>查询容器运行状态。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i10538610104519"><a name="i10538610104519"></a><a name="i10538610104519"></a>x</em>表示容器编号数字部分。</p>
</div></div>
</li></ol>
</td>
</tr>
<tr id="row51729637"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p29351091"><a name="p29351091"></a><a name="p29351091"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol28628145"></a><a name="ol28628145"></a><ol id="ol28628145"><li>显示的Kbox云手机列表中有待查询设备。</li><li>待查Kbox云手机的<strong id="b179121821182615"><a name="b179121821182615"></a><a name="b179121821182615"></a>[sys.boot_completed]</strong>参数的值为[1]，表示该Kbox云手机启动成功。</li></ol>
</td>
</tr>
<tr id="row66169923"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p58163537"><a name="p58163537"></a><a name="p58163537"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row55525677"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p1286006"><a name="p1286006"></a><a name="p1286006"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.5 Kbox云手机容器adb测试<a name="ZH-CN_TOPIC_0000002549706085"></a>

<a name="table21405834"></a>
<table><tbody><tr id="row12065858"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p37810443"><a name="p37810443"></a><a name="p37810443"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p42747077"><a name="p42747077"></a><a name="p42747077"></a>4.1.5</p>
</td>
</tr>
<tr id="row49179380"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p24106842"><a name="p24106842"></a><a name="p24106842"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p6497156"><a name="p6497156"></a><a name="p6497156"></a>验证Kbox云手机容器adb连接和断连。</p>
</td>
</tr>
<tr id="row58474406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p38806450"><a name="p38806450"></a><a name="p38806450"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p56314742"><a name="p56314742"></a><a name="p56314742"></a>无</p>
</td>
</tr>
<tr id="row37070637"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p49931641"><a name="p49931641"></a><a name="p49931641"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol33616590"></a><a name="ol33616590"></a><ol id="ol33616590"><li>Kbox云手机基本环境已部署完成。</li><li>Kbox云手机容器已启动。</li></ol>
</td>
</tr>
<tr id="row52692061"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p40198548"><a name="p40198548"></a><a name="p40198548"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol34856947"></a><a name="ol34856947"></a><ol id="ol34856947"><li>执行<strong id="b3772115523615"><a name="b3772115523615"></a><a name="b3772115523615"></a>adb connect <em id="i1224212221845"><a name="i1224212221845"></a><a name="i1224212221845"></a>[ip:port</em></strong>]连接单个容器。<div class="note" id="note8563113110131"><a name="note8563113110131"></a><a name="note8563113110131"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p75644311132"><a name="p75644311132"></a><a name="p75644311132"></a>其中<em id="i144081019114515"><a name="i144081019114515"></a><a name="i144081019114515"></a>ip:port</em>（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。</p>
</div></div>
</li><li>执行<strong id="b1717010332011"><a name="b1717010332011"></a><a name="b1717010332011"></a>adb disconnect <em id="i043391311611"><a name="i043391311611"></a><a name="i043391311611"></a>[ip:port</em></strong>]断连单个容器。</li></ol>
</td>
</tr>
<tr id="row39051693"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p9070525"><a name="p9070525"></a><a name="p9070525"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol63623897"></a><a name="ol63623897"></a><ol id="ol63623897"><li>回显“connected to <em id="i12129124831814"><a name="i12129124831814"></a><a name="i12129124831814"></a>ip:port</em>”，adb连接Kbox云手机容器成功。</li><li>回显“disconnected <em id="i4735155011188"><a name="i4735155011188"></a><a name="i4735155011188"></a>ip:port</em>”，adb断连Kbox云手机容器成功。</li></ol>
</td>
</tr>
<tr id="row9596482"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p39117597"><a name="p39117597"></a><a name="p39117597"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row62570345"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p35033180"><a name="p35033180"></a><a name="p35033180"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.6 资源隔离测试<a name="ZH-CN_TOPIC_0000002518346226"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.6</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8944133303214"><a name="p8944133303214"></a><a name="p8944133303214"></a>验证Kbox云手机资源隔离功能是否正常。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p3944933133216"><a name="p3944933133216"></a><a name="p3944933133216"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol35761342"></a><a name="ol35761342"></a><ol id="ol35761342"><li>CPU资源隔离验证：执行命令<strong id="b72277592212"><a name="b72277592212"></a><a name="b72277592212"></a>docker exec -it kbox_<em id="i3227859227"><a name="i3227859227"></a><a name="i3227859227"></a>x</em> cat /proc/cpuinfo | grep processor</strong>。</li><li>内存资源隔离验证：执行命令<strong id="b222712591623"><a name="b222712591623"></a><a name="b222712591623"></a>docker exec -it kbox_<em id="i182278592215"><a name="i182278592215"></a><a name="i182278592215"></a>x</em> cat /proc/meminfo | grep MemTotal</strong>。</li><li>存储资源隔离验证：执行命令<strong id="b12270591824"><a name="b12270591824"></a><a name="b12270591824"></a>df -h | grep -w kbox_<em id="i192271659520"><a name="i192271659520"></a><a name="i192271659520"></a>x</em></strong>。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i13578126194511"><a name="i13578126194511"></a><a name="i13578126194511"></a>x</em>表示容器编号数字部分。</p>
</div></div>
</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol5531923153611"></a><a name="ol5531923153611"></a><ol id="ol5531923153611"><li>查询到的单个容器CPU核数与特性指南中的规格相符。</li><li>查询到的单个容器内存大小与特性指南中的规格相符。</li><li>查询到的单个容器存储空间大小与特性指南中的规格相符。</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.7 GPS Mock测试<a name="ZH-CN_TOPIC_0000002549706077"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.7</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8944133303214"><a name="p8944133303214"></a><a name="p8944133303214"></a>验证<term id="term16919815172016"><a name="term16919815172016"></a><a name="term16919815172016"></a>GPS Mock</term>功能。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p3944933133216"><a name="p3944933133216"></a><a name="p3944933133216"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并连接。</li><li>容器内已安装百度地图或高德地图。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol35761342"></a><a name="ol35761342"></a><ol id="ol35761342"><li>使用ARDC连接Kbox云手机容器显示图形界面。</li><li>打开百度地图或高德地图，查看当前位置。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><p id="p1576103017170"><a name="p1576103017170"></a><a name="p1576103017170"></a>显示当前位置为Mock预置位置（华为杭研所）。</p>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.8 IMEI Mock测试<a name="ZH-CN_TOPIC_0000002518186306"></a>

<a name="table9347770"></a>
<table><tbody><tr id="row3292479"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p65364216"><a name="p65364216"></a><a name="p65364216"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p60010105"><a name="p60010105"></a><a name="p60010105"></a>4.1.8</p>
</td>
</tr>
<tr id="row3220036"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p59496389"><a name="p59496389"></a><a name="p59496389"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p54478243"><a name="p54478243"></a><a name="p54478243"></a>验证<term id="term20236727132011"><a name="term20236727132011"></a><a name="term20236727132011"></a>IMEI Mock</term>功能。</p>
</td>
</tr>
<tr id="row20542144"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p53300980"><a name="p53300980"></a><a name="p53300980"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p22412087"><a name="p22412087"></a><a name="p22412087"></a>无</p>
</td>
</tr>
<tr id="row382199"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p30958167"><a name="p30958167"></a><a name="p30958167"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol24583579"></a><a name="ol24583579"></a><ol id="ol24583579"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。</li></ol>
</td>
</tr>
<tr id="row3362700"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p3943290"><a name="p3943290"></a><a name="p3943290"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol50971113"></a><a name="ol50971113"></a><ol id="ol50971113"><li>在云手机拨号界面输入<strong id="b76751652126"><a name="b76751652126"></a><a name="b76751652126"></a><span class="parmvalue" id="parmvalue1267518522219"><a name="parmvalue1267518522219"></a><a name="parmvalue1267518522219"></a>“*#06#”</span></strong>，或在服务器端使用命令<strong id="b326071161816"><a name="b326071161816"></a><a name="b326071161816"></a>docker exec -it kbox_<em id="i811564712256"><a name="i811564712256"></a><a name="i811564712256"></a>x</em> getprop persist.sys.prop.writeimei</strong>，查询IMEI的值。</li><li>服务器端使用命令<strong id="b1583414533529"><a name="b1583414533529"></a><a name="b1583414533529"></a>docker exec -it kbox_x sh setprop persist.sys.prop.writeimei imei_num</strong>修改IMEI的值。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i2610033124513"><a name="i2610033124513"></a><a name="i2610033124513"></a>x</em>表示容器编号的数值部分。</p>
</div></div>
</li></ol>
</td>
</tr>
<tr id="row46740235"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p27862706"><a name="p27862706"></a><a name="p27862706"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol42286742"></a><a name="ol42286742"></a><ol id="ol42286742"><li>显示当前Kbox云手机容器预置的IMEI码。</li><li>服务端修改IMEI值后，再次查询显示为修改之后的IMEI值。</li></ol>
</td>
</tr>
<tr id="row2674078"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p15273779"><a name="p15273779"></a><a name="p15273779"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row61622560"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p25371443"><a name="p25371443"></a><a name="p25371443"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.9 Wi-Fi Mock测试<a name="ZH-CN_TOPIC_0000002549826083"></a>

<a name="table11771810"></a>
<table><tbody><tr id="row59149545"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p26383877"><a name="p26383877"></a><a name="p26383877"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p56719260"><a name="p56719260"></a><a name="p56719260"></a>4.1.9</p>
</td>
</tr>
<tr id="row40711298"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p9280864"><a name="p9280864"></a><a name="p9280864"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p13552494"><a name="p13552494"></a><a name="p13552494"></a>验证<term id="term1978014572014"><a name="term1978014572014"></a><a name="term1978014572014"></a>Wi-Fi Mock</term>功能。</p>
</td>
</tr>
<tr id="row54863582"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p14765176"><a name="p14765176"></a><a name="p14765176"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p55128598"><a name="p55128598"></a><a name="p55128598"></a>无</p>
</td>
</tr>
<tr id="row26395338"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p57647658"><a name="p57647658"></a><a name="p57647658"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol38948739"></a><a name="ol38948739"></a><ol id="ol38948739"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器。</li><li>Kbox云手机内已安装安兔兔（安兔兔的作用是激活Wi-Fi Mock功能）。</li></ol>
</td>
</tr>
<tr id="row59232061"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p33067631"><a name="p33067631"></a><a name="p33067631"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol197965417300"></a><a name="ol197965417300"></a><ol id="ol197965417300"><li>打开安兔兔，并授予相关权限。</li><li>进入<span class="menucascade" id="menucascade238611414408"><a name="menucascade238611414408"></a><a name="menucascade238611414408"></a>“<span class="uicontrol" id="uicontrol1738617417404"><a name="uicontrol1738617417404"></a><a name="uicontrol1738617417404"></a>首页 &gt; 我的手机 &gt; 硬件配置界面</span>”</span>查看相关配置。</li></ol>
</td>
</tr>
<tr id="row11055465"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p23077496"><a name="p23077496"></a><a name="p23077496"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><p id="p197672031872"><a name="p197672031872"></a><a name="p197672031872"></a>硬件配置界面显示Wi-Fi相关信息。</p>
</td>
</tr>
<tr id="row13856955"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p48671551"><a name="p48671551"></a><a name="p48671551"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row48080784"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p2229438"><a name="p2229438"></a><a name="p2229438"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.10 传感器Mock测试<a name="ZH-CN_TOPIC_0000002518186312"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.10</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>验证传感器Mock功能，测试的传感器包括加速度和陀螺仪。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并连接。</li><li>Kbox云手机内已安装安兔兔软件。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><p id="p16483937188"><a name="p16483937188"></a><a name="p16483937188"></a>在安兔兔软件中查看<span class="menucascade" id="menucascade46729468468"><a name="menucascade46729468468"></a><a name="menucascade46729468468"></a>“<span class="uicontrol" id="uicontrol467284654616"><a name="uicontrol467284654616"></a><a name="uicontrol467284654616"></a>我的手机</span> &gt; <span class="uicontrol" id="uicontrol076318315499"><a name="uicontrol076318315499"></a><a name="uicontrol076318315499"></a>硬件配置</span> &gt; <span class="uicontrol" id="uicontrol15412183214490"><a name="uicontrol15412183214490"></a><a name="uicontrol15412183214490"></a>传感器</span>”</span>。</p>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><p id="p10916303183"><a name="p10916303183"></a><a name="p10916303183"></a>传感器选项中有加速度/陀螺仪显示。</p>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.11 vinput设备创建<a name="vinput设备创建"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.11</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>验证能够成功创建vinput设备-鼠标/手柄。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用adb连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol179511353163010"></a><a name="ol179511353163010"></a><ol id="ol179511353163010"><li>打开一个服务器远程连接窗口A，输入命令<strong id="b2955143521"><a name="b2955143521"></a><a name="b2955143521"></a>docker exec -it kbox_<em id="i20955543123"><a name="i20955543123"></a><a name="i20955543123"></a>x</em> setprop persist.sys.input.[mouse/gamepad1/gamepad2].name <em id="i99558431424"><a name="i99558431424"></a><a name="i99558431424"></a>xxx</em></strong>分别设置鼠标/手柄1/手柄2名称。<div class="note" id="note184111456201318"><a name="note184111456201318"></a><a name="note184111456201318"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p15412956151314"><a name="p15412956151314"></a><a name="p15412956151314"></a>其中<em id="i136914211452"><a name="i136914211452"></a><a name="i136914211452"></a>x</em>表示容器编号的数值部分，<em id="i89553430220"><a name="i89553430220"></a><a name="i89553430220"></a>xxx</em>为长度不超过64个字符的字母/数字/下划线组合。</p>
</div></div>
</li><li>设置完成后，输入<strong id="b695515431524"><a name="b695515431524"></a><a name="b695515431524"></a>docker exec -it kbox_x getevent</strong>可以查询设置的设备名称。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol135411430183113"></a><a name="ol135411430183113"></a><ol id="ol135411430183113"><li>设备名称设置成功，无报错提示。</li><li>能够查询到所创建的设备并且名称正确。</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.12 vinput设备事件发送与接收<a name="ZH-CN_TOPIC_0000002518186304"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.12</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>验证vinput设备能够正常发送与接收事件。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用adb连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.5.1 "><a name="ol179511353163010"></a><a name="ol179511353163010"></a><ol id="ol179511353163010"><li>完成<a href="#vinput设备创建">4.1.11-vinput设备创建</a>相关设置后，打开另一个服务器端远程连接窗口B输入命令<strong id="b576354018211"><a name="b576354018211"></a><a name="b576354018211"></a>getevent</strong>侦听事件。</li><li>在服务器远程连接窗口A使用命令<strong id="b1976319409216"><a name="b1976319409216"></a><a name="b1976319409216"></a>docker exec -it kbox_<em id="i6763340320"><a name="i6763340320"></a><a name="i6763340320"></a>x</em> sh</strong>进入容器。输入命令<strong id="b57631240921"><a name="b57631240921"></a><a name="b57631240921"></a>getevent -p</strong>获取相应事件的<span class="parmvalue" id="parmvalue13846195210156"><a name="parmvalue13846195210156"></a><a name="parmvalue13846195210156"></a>“device”</span>、<span class="parmvalue" id="parmvalue185416558153"><a name="parmvalue185416558153"></a><a name="parmvalue185416558153"></a>“type”</span>、<span class="parmvalue" id="parmvalue963119574156"><a name="parmvalue963119574156"></a><a name="parmvalue963119574156"></a>“code”</span>、<span class="parmvalue" id="parmvalue13874081617"><a name="parmvalue13874081617"></a><a name="parmvalue13874081617"></a>“value”</span>参数。</li><li>在容器中使用命令<strong id="b1763194019210"><a name="b1763194019210"></a><a name="b1763194019210"></a>sendevent [device] [type] [code] [value]</strong>发送事件。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i6906248124519"><a name="i6906248124519"></a><a name="i6906248124519"></a>x</em>表示容器编号数字部分。</p>
</div></div>
</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.6.1 "><p id="p437614514711"><a name="p437614514711"></a><a name="p437614514711"></a>窗口A发送事件无报错，窗口B可以成功侦听到事件。</p>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.1%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.9%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.13 GPS Mock属性值修改<a name="ZH-CN_TOPIC_0000002518346228"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.13</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>验证GPS Mock各属性的数值能够修改并查询。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建1路Kbox云手机容器，并连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol179511353163010"></a><a name="ol179511353163010"></a><ol id="ol179511353163010"><li id="li1195175343017"><a name="li1195175343017"></a><a name="li1195175343017"></a>在PC端CMD窗口连接容器后输入命令<strong id="b1436317365211"><a name="b1436317365211"></a><a name="b1436317365211"></a>adb -s <em id="i736311361216"><a name="i736311361216"></a><a name="i736311361216"></a>[ip:port]</em> shell setprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed] <em id="i1036317366219"><a name="i1036317366219"></a><a name="i1036317366219"></a>xx</em></strong>分别修改GPS各属性的数值。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i67061404461"><a name="i67061404461"></a><a name="i67061404461"></a>xx</em>为各属性的合法值。<em id="i9555525349"><a name="i9555525349"></a><a name="i9555525349"></a>ip:port</em>（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。</p>
</div></div>
</li><li>在PC端CMD窗口输入命令<strong id="b1436333616211"><a name="b1436333616211"></a><a name="b1436333616211"></a>adb -s [ip:port] shell getprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed]</strong>查询GPS各属性的数值。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol135411430183113"></a><a name="ol135411430183113"></a><ol id="ol135411430183113"><li>无设置失败报错提示。</li><li>能够查询到测试步骤<a href="#li1195175343017">1</a>中设置的GPS各属性数值，且数值正确。</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.14 传感器属性值设置<a name="ZH-CN_TOPIC_0000002549706079"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.14</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>验证传感器Mock的x/y/z三轴属性值以及数据采集频率属性值能够修改。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用adb连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol16121093219"></a><a name="ol16121093219"></a><ol id="ol16121093219"><li>在PC端CMD窗口或服务器端输入命令<strong id="b1361151014324"><a name="b1361151014324"></a><a name="b1361151014324"></a>adb -s [ip:port] shell setprop persist.sensors.mock.[acce/gyro].data.[x/y/z] <em id="i114689531503"><a name="i114689531503"></a><a name="i114689531503"></a>xx</em></strong>（<em id="i126101017324"><a name="i126101017324"></a><a name="i126101017324"></a>xx</em>为&plusmn;3.402823466e+38内任意值）修改传感器（acce表示加速度传感器，gyro表示陀螺仪传感器）的x/y/z三轴参数。</li><li>打开sensors_test.apk查询传感器各属性的数值。</li><li>在PC端CMD窗口或服务器端输入命令<strong id="b196121017325"><a name="b196121017325"></a><a name="b196121017325"></a>adb -s [ip:port] shell setprop persist.sensors.mock.delaytime <em id="i174691053104"><a name="i174691053104"></a><a name="i174691053104"></a>xx</em></strong>（<em id="i16111053214"><a name="i16111053214"></a><a name="i16111053214"></a>xx</em>为[20000,1000000]任意值）设置传感器Mock中的数据采集频率属性值。</li><li>再次执行步骤1与步骤2。</li><li>观察修改数据采集频率之后所修改的传感器的属性值的变化时长。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol31291241193210"></a><a name="ol31291241193210"></a><ol id="ol31291241193210"><li>设置过程无报错。</li><li>能够成功设置各参数。</li><li>能够成功查询各参数。</li><li>修改数据采集频率为不同的数值之后传感器的属性值变化的时长不同。</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.15 Kbox组件版本号查询测试<a name="ZH-CN_TOPIC_0000002518346230"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.15</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>Kbox组件版本号查询测试。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用adb连接。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol16121093219"></a><a name="ol16121093219"></a><ol id="ol16121093219"><li>执行<strong id="b22264237518"><a name="b22264237518"></a><a name="b22264237518"></a>sudo docker exec -it kbox_<em id="i18947227205110"><a name="i18947227205110"></a><a name="i18947227205110"></a>x</em> sh</strong>进入Kbox云手机容器，出现结果1。</li><li>执行<strong id="b16783234114910"><a name="b16783234114910"></a><a name="b16783234114910"></a>cat /vendor/etc/kbox_version.txt</strong>查询版本号内容，出现结果2。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol31291241193210"></a><a name="ol31291241193210"></a><ol id="ol31291241193210"><li>容器可以正常进入。</li><li>文件内容包含Kbox组件版本信息如下，且版本信息准确。（具体版本号以当前版本为准。）<a name="screen6861017369"></a><a name="screen6861017369"></a><pre class="screen" codetype="ColdFusion" id="screen6861017369">Product Name: Kunpeng BoostKit
Product Version: xxx
Component Name: BoostKit-boostcph-kbox
Component Version: xxx
Component AppendInfo: 11.0.0_r48</pre>
</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.16 Kbox云手机硬解视频播放能力测试<a name="ZH-CN_TOPIC_0000002518346232"></a>

<a name="table60533823"></a>
<table><tbody><tr id="row18289549"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.1.1"><p id="p5058482"><a name="p5058482"></a><a name="p5058482"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.1.1 "><p id="p7083912"><a name="p7083912"></a><a name="p7083912"></a>4.1.16</p>
</td>
</tr>
<tr id="row63755213"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.2.1"><p id="p63898606"><a name="p63898606"></a><a name="p63898606"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.2.1 "><p id="p8404629"><a name="p8404629"></a><a name="p8404629"></a>Kbox云手机硬解视频播放能力测试。</p>
</td>
</tr>
<tr id="row8532797"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.3.1"><p id="p20067941"><a name="p20067941"></a><a name="p20067941"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.3.1 "><p id="p14890501"><a name="p14890501"></a><a name="p14890501"></a>无</p>
</td>
</tr>
<tr id="row66905650"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.4.1"><p id="p50648570"><a name="p50648570"></a><a name="p50648570"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.4.1 "><a name="ol8893519"></a><a name="ol8893519"></a><ol id="ol8893519"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用adb连接。</li><li>Kbox云手机容器已安装Xplayer。</li></ol>
</td>
</tr>
<tr id="row32777406"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.5.1"><p id="p37724200"><a name="p37724200"></a><a name="p37724200"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.5.1 "><a name="ol16121093219"></a><a name="ol16121093219"></a><ol id="ol16121093219"><li>已按照特性指南的指导将Kbox云手机设置为使用NETINT T432/NETINT QUADRA T2A编解码卡的硬件解码器。</li><li>容器导入264_1280x720_30fps/265_1280x720_30fps格式视频。</li><li>使用Xplayer对导入视频进行完整播放，出现结果预期结果1。</li></ol>
</td>
</tr>
<tr id="row31779770"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.6.1"><p id="p24024607"><a name="p24024607"></a><a name="p24024607"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.6.1 "><a name="ol662636316"></a><a name="ol662636316"></a><ol id="ol662636316"><li>视频播放过程画面正常，不出现卡顿，未出现异常帧（如花屏、黑屏、绿屏等）画面现象，且日志能够查询到硬件解码器名称OMX.media.video.decoder。</li></ol>
</td>
</tr>
<tr id="row53838891"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.7.1"><p id="p65982881"><a name="p65982881"></a><a name="p65982881"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row51573979"><th class="firstcol" valign="top" width="22.2%" id="mcps1.1.3.8.1"><p id="p16742774"><a name="p16742774"></a><a name="p16742774"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.8%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.17 IMSI Mock测试<a name="ZH-CN_TOPIC_0000002549706081"></a>

<a name="table9347770"></a>
<table><tbody><tr id="row3292479"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p65364216"><a name="p65364216"></a><a name="p65364216"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p60010105"><a name="p60010105"></a><a name="p60010105"></a>4.1.17</p>
</td>
</tr>
<tr id="row3220036"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p59496389"><a name="p59496389"></a><a name="p59496389"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p54478243"><a name="p54478243"></a><a name="p54478243"></a>验证IMSI Mock功能。</p>
</td>
</tr>
<tr id="row20542144"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p53300980"><a name="p53300980"></a><a name="p53300980"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p22412087"><a name="p22412087"></a><a name="p22412087"></a>无</p>
</td>
</tr>
<tr id="row382199"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p30958167"><a name="p30958167"></a><a name="p30958167"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol24583579"></a><a name="ol24583579"></a><ol id="ol24583579"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。</li></ol>
</td>
</tr>
<tr id="row3362700"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p3943290"><a name="p3943290"></a><a name="p3943290"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol50971113"></a><a name="ol50971113"></a><ol id="ol50971113"><li>在云手机拨号界面输入<strong id="b759522422"><a name="b759522422"></a><a name="b759522422"></a><span class="parmvalue" id="parmvalue16594222213"><a name="parmvalue16594222213"></a><a name="parmvalue16594222213"></a>“*#*#4636#*#*”</span></strong>，查询IMSI的值。</li><li>PC终端窗口执行命令<strong id="b2595228215"><a name="b2595228215"></a><a name="b2595228215"></a>adb connect <em id="i145918226212"><a name="i145918226212"></a><a name="i145918226212"></a>[ip:port]</em></strong>连接指定容器</li><li>PC终端窗口执行命令<strong id="b135952212216"><a name="b135952212216"></a><a name="b135952212216"></a>adb -s <em id="i175916221128"><a name="i175916221128"></a><a name="i175916221128"></a>[ip:port]</em> shell setprop persist.sys.prop.writeimsi <em id="i8591422526"><a name="i8591422526"></a><a name="i8591422526"></a>xx</em></strong>，重启kbox云手机，重新查询IMSI的值。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i199621710154618"><a name="i199621710154618"></a><a name="i199621710154618"></a>x</em>x表示IMSI参数的合法数值。</p>
</div></div>
</li></ol>
</td>
</tr>
<tr id="row46740235"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p27862706"><a name="p27862706"></a><a name="p27862706"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol42286742"></a><a name="ol42286742"></a><ol id="ol42286742"><li>显示当前Kbox云手机容器预置的IMSI码默认初始值：46011+随机数字。</li><li>服务端修改IMSI值后，再次查询显示为修改之后的IMSI值。</li></ol>
</td>
</tr>
<tr id="row2674078"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p15273779"><a name="p15273779"></a><a name="p15273779"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row61622560"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p25371443"><a name="p25371443"></a><a name="p25371443"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

#### 4.1.18 网络运营商信息、SIM卡信息查询测试<a name="ZH-CN_TOPIC_0000002518186308"></a>

<a name="table9347770"></a>
<table><tbody><tr id="row3292479"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.1.1"><p id="p65364216"><a name="p65364216"></a><a name="p65364216"></a>用例编号</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.1.1 "><p id="p60010105"><a name="p60010105"></a><a name="p60010105"></a>4.1.18</p>
</td>
</tr>
<tr id="row3220036"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.2.1"><p id="p59496389"><a name="p59496389"></a><a name="p59496389"></a>测试目的</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.2.1 "><p id="p54478243"><a name="p54478243"></a><a name="p54478243"></a>验证网络运营商信息、SIM卡信息查询功能。</p>
</td>
</tr>
<tr id="row20542144"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.3.1"><p id="p53300980"><a name="p53300980"></a><a name="p53300980"></a>测试组网</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.3.1 "><p id="p22412087"><a name="p22412087"></a><a name="p22412087"></a>无</p>
</td>
</tr>
<tr id="row382199"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.4.1"><p id="p30958167"><a name="p30958167"></a><a name="p30958167"></a>预置条件</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.4.1 "><a name="ol24583579"></a><a name="ol24583579"></a><ol id="ol24583579"><li>Kbox云手机基本环境已部署完成。</li><li>已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。</li><li>Kbox云手机容器已安装zausan.zdevicetest.apk。</li></ol>
</td>
</tr>
<tr id="row3362700"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.5.1"><p id="p3943290"><a name="p3943290"></a><a name="p3943290"></a>测试步骤</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.5.1 "><a name="ol50971113"></a><a name="ol50971113"></a><ol id="ol50971113"><li>在服务端执行<strong id="b22264237518"><a name="b22264237518"></a><a name="b22264237518"></a>sudo docker exec -it kbox_<em id="i18947227205110"><a name="i18947227205110"></a><a name="i18947227205110"></a>x</em> sh</strong>进入Kbox云手机容器。</li><li>输入<strong id="b1394713120217"><a name="b1394713120217"></a><a name="b1394713120217"></a>dumpsys isub | grep iccid</strong>查询SIM卡序列号，出现预期结果1。</li><li>在客户端打开zausan.zdevicetest.apk中的SSM/UMTS。</li><li>查看SIM operator/SIM operator name/SIM country/Network operator/Network operator name/Network country/Line one number，得到SIM卡运营商代码、SIM卡运营商名字、SIM卡运营商国家码、网络运营商代码、网络运营商名字、网络运营商国家码、手机号码，出现结果2。</li><li>在PC端CMD窗口连接容器后输入命令<strong id="b189474121529"><a name="b189474121529"></a><a name="b189474121529"></a>adb -s <em id="i294711121323"><a name="i294711121323"></a><a name="i294711121323"></a>[ip:port]</em> shell setprop persist.[sys.prop.writesimserial/gsm.sim.operator.alphacph/sys.prop.writeimsi/gsm.operator.numericcph/gsm.operator.alphacph/gsm.operator.numericcph/sys.prop.writephonenum] <em id="i189488121421"><a name="i189488121421"></a><a name="i189488121421"></a>xx</em></strong>分别修改各属性。<div class="note" id="note554619383117"><a name="note554619383117"></a><a name="note554619383117"></a><span class="notetitle"> 说明： </span><div class="notebody"><p id="p254633816115"><a name="p254633816115"></a><a name="p254633816115"></a>其中<em id="i1754816164613"><a name="i1754816164613"></a><a name="i1754816164613"></a>xx</em>为各属性的合法值。<em id="i9555525349"><a name="i9555525349"></a><a name="i9555525349"></a>ip:port</em>（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。</p>
</div></div>
</li><li>重启Kbox云手机，重新查询各数值，出现结果3。</li></ol>
</td>
</tr>
<tr id="row46740235"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.6.1"><p id="p27862706"><a name="p27862706"></a><a name="p27862706"></a>预期结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.6.1 "><a name="ol42286742"></a><a name="ol42286742"></a><ol id="ol42286742"><li>显示当前Kbox云手机容器预置的SIM卡序列号默认初始值：898600+随机数字。</li><li>显示当前Kbox云手机容器预置的SIM卡运营商代码、SIM卡运营商名字、SIM卡运营商国家码、网络运营商代码、网络运营商名字和网络运营商国家码默认初始值分别为：46011/CMCC/cn/46000/CMCC/cn，手机号码默认初始值为空值。</li><li>显示当前Kbox云手机容器修改后的值。</li></ol>
</td>
</tr>
<tr id="row2674078"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.7.1"><p id="p15273779"><a name="p15273779"></a><a name="p15273779"></a>测试结果</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.7.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row61622560"><th class="firstcol" valign="top" width="22.220000000000002%" id="mcps1.1.3.8.1"><p id="p25371443"><a name="p25371443"></a><a name="p25371443"></a>备注</p>
</th>
<td class="cellrowborder" valign="top" width="77.78%" headers="mcps1.1.3.8.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

## 5 测试结果分析<a name="ZH-CN_TOPIC_0000002549826081"></a>

### 5.1 测试基本信息<a name="ZH-CN_TOPIC_0000002518346222"></a>

<a name="table56604068"></a>
<table><tbody><tr id="row35370789"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.1.1"><p id="p46461622"><a name="p46461622"></a><a name="p46461622"></a>设备制造商</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.1.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row47655290"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.2.1"><p id="p34873320"><a name="p34873320"></a><a name="p34873320"></a>设备型号</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.2.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row55500145"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.3.1"><p id="p66326724"><a name="p66326724"></a><a name="p66326724"></a>测试地点</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.3.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row33800412"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.4.1"><p id="p53478832"><a name="p53478832"></a><a name="p53478832"></a>测试人员</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.4.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row62927705"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.5.1"><p id="p63979351"><a name="p63979351"></a><a name="p63979351"></a>测试时间</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.5.1 ">&nbsp;&nbsp;</td>
</tr>
<tr id="row287118"><th class="firstcol" valign="top" width="21.07%" id="mcps1.1.3.6.1"><p id="p23256560"><a name="p23256560"></a><a name="p23256560"></a>其余信息</p>
</th>
<td class="cellrowborder" valign="top" width="78.93%" headers="mcps1.1.3.6.1 ">&nbsp;&nbsp;</td>
</tr>
</tbody>
</table>

### 5.2 测试结果列表<a name="ZH-CN_TOPIC_0000002549826079"></a>

|测试类别|用例编号|用例名称|测试结果（PASS/FAIL/NT）|
|--|--|--|--|
|基本功能测试|4.1.1|创建Kbox云手机容器||
||4.1.2|重启Kbox云手机容器||
||4.1.3|删除Kbox云手机容器||
||4.1.4|Kbox云手机容器状态查询||
||4.1.5|Kbox云手机容器adb测试||
||4.1.6|资源隔离测试||
||4.1.7|GPS Mock测试||
||4.1.8|IMEI Mock测试||
||4.1.9|Wi-Fi Mock测试||
||4.1.10|传感器Mock测试||
||4.1.11|vinput设备创建||
||4.1.12|vinput设备事件发送与接收||
||4.1.13|GPS Mock属性值修改||
||4.1.14|传感器属性值设置||
||4.1.15|Kbox组件版本号查询测试||
||4.1.16|Kbox云手机硬解视频播放能力测试||
||4.1.17|IMSI Mock测试||
||4.1.18|网络运营商信息、SIM卡信息查询测试||

## 6 客户建议及结果确认<a name="ZH-CN_TOPIC_0000002549826075"></a>

### 6.1 客户建议<a name="ZH-CN_TOPIC_0000002549706083"></a>

### 6.2 结果确认<a name="ZH-CN_TOPIC_0000002549826073"></a>

|被测试方：华为技术有限公司|测试方：|
|--|--|
|测试人员签名：|测试人员签名：|
|时间：|时间：|
