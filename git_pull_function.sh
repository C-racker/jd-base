#!/bin/bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-11-23
## Version： v2.3.2

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/data/data/com.termux/files/usr/bin"
export LC_ALL=C


################################## 定义文件路径（勿动） ##################################
RootDir=$(cd $(dirname $0); cd ..; pwd)
LogDir=${RootDir}/log
ScriptsDir=${RootDir}/scripts
ScriptsURL=https://github.com/lxk0301/jd_scripts
ShellURL=https://github.com/EvineDeng/jd-base
FileJdSample=${ShellDir}/jd.sh.sample
ListShell=${LogDir}/shell.list
ListJs=${LogDir}/js.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
ListCron=${RootDir}/crontab.list
ListShellDir=$(ls ${ShellDir}/jd_*.sh)


################################## 定义js脚本名称 ##################################
FileBeanSign=jd_bean_sign.js
FileCookie=jdCookie.js
FileNotify=sendNotify.js
FileFruitShareCodes=jdFruitShareCodes.js
FilePetShareCodes=jdPetShareCodes.js
FilePlantBeanShareCodes=jdPlantBeanShareCodes.js
FileSuperMarketShareCodes=jdSuperMarketShareCodes.js
FileJoy=jd_joy.js
FileJoyFeed=jd_joy_feedPets.js
FileJoyReward=jd_joy_reward.js
FileJoySteal=jd_joy_steal.js
FileBlueCoin=jd_blueCoin.js
FileSuperMarket=jd_superMarket.js
FileFruit=jd_fruit.js
FilePet=jd_pet.js
File818=jd_818.js
FileUnsubscribe=jd_unsubscribe.js
FileDreamFactory=jd_dreamFactory.js
FileMoneyTree=jd_moneyTree.js


################################## 在日志中记录时间与路径 ##################################
echo -e "\n-------------------------------------------------------------------\n"
echo -n "系统时间："
echo $(date "+%Y-%m-%d %H:%M:%S")
if [ "${TZ}" = "UTC" ]; then
  echo
  echo -n "北京时间："
  echo $(date -d "8 hour" "+%Y-%m-%d %H:%M:%S")
fi
echo -e "\nSHELL脚本目录：${ShellDir}\n"
echo -e "JS脚本目录：${ScriptsDir}\n"
echo -e "-------------------------------------------------------------------\n"


################################## 检测jd_*.sh文件是否最新 ##################################
function Detect_VerJdShell {
  VerSample=$(cat ${FileJdSample} | grep -i "Version" | perl -pe "s|.+v((\d\.){2}\d)|\1|")
  for file in ${ListShellDir}
  do
    VerJdShell=$(cat ${file} | grep -i "Version" | perl -pe "s|.+v((\d\.){2}\d)|\1|")
    if [ -z "${VerJdShell}" ] || [ "${VerJdShell}" != "${VerSample}" ]; then
      cp -f ${FileJdSample} ${file}
    fi
  done
}


################################## 判断是否输入用户数量 ##################################
function Detect_UserSum {
  if [ -z "${UserSum}" ]; then
    echo -e "请输入有效的用户数量(UserSum)...\n"
    exit 1
  fi
}


################################## git更新JS脚本 ##################################
function Git_PullScripts {
  echo -e "更新JS脚本，原地址：${ScriptsURL}\n"
  git fetch --all
  git reset --hard origin/master
  git pull
  echo
}


################################## 修改JS脚本中的Cookie ##################################
function Change_Cookie {
  CookieALL=""
  echo -e "${FileCookie}: 替换Cookies...\n"
  ii=1
  while [ ${ii} -le ${UserSum} ]
  do
    Temp1=Cookie${ii}
    eval CookieTemp=$(echo \$${Temp1})
    CookieALL="${CookieALL}\\n  '${CookieTemp}',"
    let ii++
  done
  perl -0777 -i -pe "s|let CookieJDs = \[\n(.+\n?){2}\]|let CookieJDs = \[${CookieALL}\n\]|" ${FileCookie}
}


################################## 修改通知TOKEN ##################################
function Change_Token {
  ## ServerChan
  if [ ${SCKEY} ]; then
    echo -e "${FileNotify}: 替换ServerChan推送通知SCKEY...\n"
    perl -i -pe "s|let SCKEY = '';|let SCKEY = '${SCKEY}';|" ${FileNotify}
  fi

  ## BARK
  if [ ${BARK_PUSH} ] && [ ${BARK_SOUND} ]; then
    echo -e "${FileNotify}: 替换BARK推送通知BARK_PUSH、BARK_SOUND...\n"
    perl -i -pe "s|let BARK_PUSH = '';|let BARK_PUSH = '${BARK_PUSH}';|" ${FileNotify}
    perl -i -pe "s|let BARK_SOUND = '';|let BARK_SOUND = '${BARK_SOUND}';|" ${FileNotify}
  fi

  ## Telegram
  if [ ${TG_BOT_TOKEN} ] && [ ${TG_USER_ID} ]; then
    echo -e "${FileNotify}: 替换Telegram推送通知TG_BOT_TOKEN、TG_USER_ID...\n"
    perl -i -pe "s|let TG_BOT_TOKEN = '';|let TG_BOT_TOKEN = '${TG_BOT_TOKEN}';|" ${FileNotify}
    perl -i -pe "s|let TG_USER_ID = '';|let TG_USER_ID = '${TG_USER_ID}';|" ${FileNotify}
  fi

  ## 钉钉
  if [ ${DD_BOT_TOKEN} ]; then
    echo -e "${FileNotify}: 替换钉钉推送通知DD_BOT...\n"
    perl -i -pe "s|let DD_BOT_TOKEN = '';|let DD_BOT_TOKEN = '${DD_BOT_TOKEN}';|" ${FileNotify}
    if [ ${DD_BOT_SECRET} ]; then
      perl -i -pe "s|let DD_BOT_SECRET = '';|let DD_BOT_SECRET = '${DD_BOT_SECRET}';|" ${FileNotify}
    fi
  fi

  ## iGot
  if [ ${IGOT_PUSH_KEY} ]; then
    echo -e "${FileNotify}: 替换iGot推送KEY...\n"
    perl -i -pe "s|let IGOT_PUSH_KEY = '';|let IGOT_PUSH_KEY = '${IGOT_PUSH_KEY}';|" ${FileNotify}
  fi
  
  ## 未输入任何通知渠道
  if [ -z "${SCKEY}" ] && [ -z "${BARK_PUSH}" ] && [ -z "${BARK_SOUND}" ] && [ -z "${TG_BOT_TOKEN}" ] && [ -z "${TG_USER_ID}" ] && [ -z "${DD_BOT_TOKEN}" ] && [ -z "${DD_BOT_SECRET}" ] && [ -z "${IGOT_PUSH_KEY}" ]; then
    echo -e "没有有效的通知渠道，将不发送任何通知，请直接在本地查看日志...\n"
  fi
}


################################## 修改每日签到的延迟时间 ##################################
function Change_BeanSignStop {
  if [ ${BeanSignStop} ] && [ ${BeanSignStop} -gt 0 ]; then
    echo -e "${FileBeanSign}：设置每日签到每个接口延迟时间为 ${BeanSignStop} ms...\n"
    perl -0777 -i -pe "s|if \(process\.env\.JD_BEAN_STOP.+\{\n\s{2,}(.+, ).+\);\n\s*\}|\1\"var stop = ${BeanSignStop}\"\);|" ${FileBeanSign}
  fi
}


################################## 替换东东农场互助码 ##################################
function Change_FruitShareCodes {
  ForOtherFruitALL=""
  echo -e "${FileFruitShareCodes}: 替换东东农场互助码...\n"
  ij=1
  while [ ${ij} -le ${UserSum} ]
  do
    Temp2=ForOtherFruit${ij}
    eval ForOtherFruitTemp=$(echo \$${Temp2})
    ForOtherFruitALL="${ForOtherFruitALL}\\n  '${ForOtherFruitTemp}',"
    let ij++
  done
  perl -0777 -i -pe "s|let FruitShareCodes = \[\n(.+\n?){2}\]|let FruitShareCodes = \[${ForOtherFruitALL}\n\]|" ${FileFruitShareCodes}
}


################################## 替换东东萌宠互助码 ##################################
function Change_PetShareCodes {
  ForOtherPetALL=""
  echo -e "${FilePetShareCodes}: 替换东东萌宠互助码...\n"
  ik=1
  while [ ${ik} -le ${UserSum} ]
  do
    Temp3=ForOtherPet${ik}
    eval ForOtherPetTemp=$(echo \$${Temp3})
    ForOtherPetALL="${ForOtherPetALL}\\n  '${ForOtherPetTemp}',"
    let ik++
  done
  perl -0777 -i -pe "s|let PetShareCodes = \[\n(.+\n?){2}\]|let PetShareCodes = \[${ForOtherPetALL}\n\]|" ${FilePetShareCodes}
}


################################## 替换种豆得豆互助码 ##################################
function Change_PlantBeanShareCodes {
  ForOtherPlantBeanALL=""
  echo -e "${FilePlantBeanShareCodes}: 替换种豆得豆互助码...\n"
  il=1
  while [ ${il} -le ${UserSum} ]
  do
    Temp4=ForOtherPlantBean${il}
    eval ForOtherPlantBeanTemp=$(echo \$${Temp4})
    ForOtherPlantBeanALL="${ForOtherPlantBeanALL}\\n  '${ForOtherPlantBeanTemp}',"
    let il++
  done
  perl -0777 -i -pe "s|let PlantBeanShareCodes = \[\n(.+\n?){2}\]|let PlantBeanShareCodes = \[${ForOtherPlantBeanALL}\n\]|" ${FilePlantBeanShareCodes}
}


################################## 修改东东超市蓝币兑换数量 ##################################
function Change_coinToBeans {
  expr ${coinToBeans} "+" 10 &>/dev/null
  if [ $? -eq 0 ]
  then
    case ${coinToBeans} in 
      [1-9] | 1[0-9] | 20 | 1000)
        echo -e "${FileBlueCoin}: 设置东东超市蓝币兑换 ${coinToBeans} 个京豆...\n"
        perl -i -pe "s|let coinToBeans = .+;|let coinToBeans = ${coinToBeans};|" ${FileBlueCoin}
        ;;
      0)
        echo -e "${FileBlueCoin}: 设置东东超市不自动兑换蓝币...\n"
        ;;
    esac
  else
    echo -e "${FileBlueCoin}: 设置东东超市蓝币兑换实物奖品 \"${coinToBeans}\"，该奖品是否可兑换以js运行日志为准...\n"
    perl -i -pe "s|let coinToBeans = .+;|let coinToBeans = \'${coinToBeans}\';|" ${FileBlueCoin}
  fi
}


################################## 修改东东超市蓝币成功兑换奖品是否静默运行 ##################################
function Change_NotifyBlueCoin {
  if [ "${NotifyBlueCoin}" = "true" ]  || [ "${NotifyBlueCoin}" = "false" ]; then
    echo -e "${FileBlueCoin}：设置东东超市成功兑换蓝币是否静默运行为 ${NotifyBlueCoin}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyBlueCoin};|" ${FileBlueCoin}
  fi
}


################################## 修改东东超市是否自动升级商品和货架 ##################################
function Change_superMarketUpgrade {
  if [ "${superMarketUpgrade}" = "false" ]  || [ "${superMarketUpgrade}" = "true" ]; then
    echo -e "${FileSuperMarket}：设置东东超市是否自动升级商品和货架为 ${superMarketUpgrade}...\n"
    perl -i -pe "s|let superMarketUpgrade = .+;|let superMarketUpgrade = ${superMarketUpgrade};|" ${FileSuperMarket}
  fi
}


################################## 修改东东超市是否自动更换商圈 ##################################
function Change_businessCircleJump {
  if [ "${businessCircleJump}" = "false" ] || [ "${businessCircleJump}" = "true" ]; then
    echo -e "${FileSuperMarket}：设置东东超市在小于对方300热力值时是否自动更换商圈为 ${businessCircleJump}\n"
    perl -i -pe "s|let businessCircleJump = .+;|let businessCircleJump = ${businessCircleJump};|" ${FileSuperMarket}
  fi
}


################################## 修改东东超市是否自动使用金币去抽奖 ##################################
function Change_drawLotteryFlag {
  if [ "${drawLotteryFlag}" = "true" ] || [ "${drawLotteryFlag}" = "false" ]; then
    echo -e "${FileSuperMarket}：设置东东超市是否自动使用金币去抽奖为 ${drawLotteryFlag}...\n"
    perl -i -pe "s|let drawLotteryFlag = .+;|let drawLotteryFlag = ${drawLotteryFlag};|" ${FileSuperMarket}
  fi
}


################################## 修改东东农场是否静默运行 ##################################
function Change_NotifyFruit {
  if [ "${NotifyFruit}" = "true" ] || [ "${NotifyFruit}" = "false" ]; then
    echo -e "${FileFruit}：设置东东农场是否静默运行为 ${NotifyFruit}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyFruit};|" ${FileFruit}
  fi
}


################################## 修改东东农场是否使用水滴换豆卡 ##################################
function Change_jdFruitBeanCard {
  if [ "${jdFruitBeanCard}" = "true" ] || [ "${jdFruitBeanCard}" = "false" ]; then
    echo -e "${FileFruit}：设置东东农场在出现限时活动时是否使用水滴换豆卡为 ${jdFruitBeanCard}...\n"
    perl -i -pe "s|let jdFruitBeanCard = .+;|let jdFruitBeanCard = ${jdFruitBeanCard};|" ${FileFruit}
  fi
}


################################## 修改宠汪汪喂食克数 ##################################
function Change_joyFeedCount {
  case ${joyFeedCount} in
    [1248]0)
      echo -e "${FileJoy}: 设置宠汪汪喂食克数为：${joyFeedCount}g...\n"
      echo -e "${FileJoyFeed}: 设置宠汪汪喂食克数为：${joyFeedCount}g...\n"
      perl -i -pe "s|let FEED_NUM = .+;|let FEED_NUM = ${joyFeedCount};|" ${FileJoy} ${FileJoyFeed}
      ;;
  esac
}


################################## 修改宠汪汪兑换京豆数量 ##################################
function Change_joyRewardName {
  case ${joyRewardName} in
    0)
      echo -e "${FileJoyReward}：禁用宠汪汪自动兑换京豆...\n"
      perl -i -pe "s|let joyRewardName = .+;|let joyRewardName = ${joyRewardName};|" ${FileJoyReward}
      ;;
    20 | 500 | 1000)
      echo -e "${FileJoyReward}：设置宠汪汪兑换京豆数量为 ${joyRewardName}...\n"
      perl -i -pe "s|let joyRewardName = .+;|let joyRewardName = ${joyRewardName};|" ${FileJoyReward}
      ;;
  esac
}


################################## 修改宠汪汪兑换京豆是否静默运行 ##################################
function Change_NotifyJoyReward {
  if [ "${NotifyJoyReward}" = "true" ] || [ "${NotifyJoyReward}" = "false" ]; then
    echo -e "${FileJoyReward}：设置宠汪汪兑换京豆是否静默运行为 ${NotifyJoyReward}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyJoyReward};|" ${FileJoyReward}
  fi
}


################################## 修改宠汪汪偷取好友积分与狗粮是否静默运行 ##################################
function Change_NotifyJoySteal {
  if [ "${NotifyJoySteal}" = "true" ] || [ "${NotifyJoySteal}" = "false" ]; then
    echo -e "${FileJoySteal}：设置宠汪汪成功偷取好友积分与狗粮是否静默运行为 ${NotifyJoySteal}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyJoySteal};|" ${FileJoySteal}
  fi
}


################################## 修改宠汪汪是否静默运行 ##################################
function Change_NotifyJoy {
  if [ "${NotifyJoy}" = "false" ] || [ "${NotifyJoy}" = "true" ]; then
    echo -e "${FileJoy}：设置宠汪汪是否静默运行为 ${NotifyJoy}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyJoy};|" ${FileJoy}
  fi
}


################################## 修改宠汪汪是否自动报名宠物赛跑 ##################################
function Change_joyRunFlag {
  if [ "${joyRunFlag}" = "false" ] || [ "${joyRunFlag}" = "true" ]; then
    echo -e "${FileJoy}：设置宠汪汪是否自动报名宠物赛跑为 ${joyRunFlag}...\n"
    perl -i -pe "s|let joyRunFlag = .+;|let joyRunFlag = ${joyRunFlag};|" ${FileJoy}
  fi
}


################################## 修改宠汪汪是否自动给好友的汪汪喂食 ##################################
function Change_jdJoyHelpFeed {
  if [ "${jdJoyHelpFeed}" = "true" ] || [ "${jdJoyHelpFeed}" = "false" ]; then
    echo -e "${FileJoySteal}：设置宠汪汪是否自动给好友的汪汪喂食为 ${jdJoyHelpFeed}...\n"
    perl -i -pe "s|let jdJoyHelpFeed = .+;|let jdJoyHelpFeed = ${jdJoyHelpFeed};|" ${FileJoySteal}
  fi
}


################################## 修改宠汪汪是否自动偷好友积分与狗粮 ##################################
function Change_jdJoyStealCoin {
  if [ "${jdJoyStealCoin}" = "false" ] || [ "${jdJoyStealCoin}" = "true" ]; then
    echo -e "${FileJoySteal}：设置宠汪汪是否自动偷好友积分与狗粮为 ${jdJoyStealCoin}...\n"
    perl -i -pe "s|let jdJoyStealCoin = .+;|let jdJoyStealCoin = ${jdJoyStealCoin};|" ${FileJoySteal}
  fi
}


################################## 修改摇钱树是否静默运行 ##################################
function Change_NotifyMoneyTree {
  if [ "${NotifyMoneyTree}" = "false" ] || [ "${NotifyMoneyTree}" = "true" ]; then
    echo -e "${FileMoneyTree}：设置摇钱树是否静默运行为 ${NotifyMoneyTree}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyJoy};|" ${FileMoneyTree}
  fi
}


################################## 修改摇钱树是否是否自动将金果卖出变成金币 ##################################
function Change_MoneyTreeAutoSell {
  if [ "${MoneyTreeAutoSell}" = "false" ]; then
    echo -e "${FileMoneyTree}：设置摇钱树是否自动将金果卖出变成金币为 ${MoneyTreeAutoSell}...\n"
    perl -0777 -i -pe "s|if \(process\.env\.MONEY_TREE_SELL_FRUIT.+\{\n\s{2,}(\S+\n)\s{2,}(\S+\n)\s+\}\n|\1        \2|" ${FileMoneyTree}
  fi
}


################################## 修改东东萌宠是否静默运行 ##################################
function Change_NotifyPet {
  if [ "${NotifyPet}" = "true" ] || [ "${NotifyPet}" = "false" ]; then
    echo -e "${FilePet}：设置东东萌宠是否静默运行为 ${NotifyPet}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyPet};|" ${FilePet}
  fi
}


################################## 修改京喜工厂是否静默运行 ##################################
function Change_NotifyDreamFactory {
  if [ "${NotifyDreamFactory}" = "false" ] || [ "${NotifyDreamFactory}" = "true" ]; then
    echo -e "${FileDreamFactory}：设置京喜工厂是否静默运行为 ${NotifyDreamFactory}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${NotifyDreamFactory};|" ${FileDreamFactory}
  fi
}


################################## 修改取关参数 ##################################
function Change_Unsubscribe {
  if [ ${goodPageSize} ] && [ ${goodPageSize} -gt 0 ]; then
    echo -e "${FileUnsubscribe}：设置商品取关数量为 ${goodPageSize}...\n"
    perl -i -pe "s|let goodPageSize = .+;|let goodPageSize = ${goodPageSize};|" ${FileUnsubscribe}
  fi
  if [ ${shopPageSize} ] && [ ${shopPageSize} -gt 0 ]; then
    echo -e "${FileUnsubscribe}：设置店铺取关数量为 ${shopPageSize}...\n"
    perl -i -pe "s|let shopPageSize = .+;|let shopPageSize = ${shopPageSize};|" ${FileUnsubscribe}
  fi
  if [ ${jdUnsubscribeStopGoods} ]; then
    echo -e "设置禁止取关商品的截止关键字为 ${jdUnsubscribeStopGoods}，遇到此商品不再取关此商品以及它后面的商品...\n"
    perl -i -pe "s|let stopGoods = .+;|let stopGoods = \'${jdUnsubscribeStopGoods}\';|" ${FileUnsubscribe}
  fi
  if [ ${jdUnsubscribeStopShop} ]; then
    echo -e "设置禁止取关店铺的截止关键字为 ${jdUnsubscribeStopShop}，遇到此店铺不再取关此店铺以及它后面的店铺...\n"
    perl -i -pe "s|let stopShop = .+;|let stopShop = \'${jdUnsubscribeStopShop}\';|" ${FileUnsubscribe}
  fi
}


################################## 修改手机狂欢城是否发送上车提醒 ##################################
function Change_Notify818 {
  if [ "${Notify818}" = "true" ] || [ "${Notify818}" = "false" ]; then
    echo -e "${File818}：设置手机狂欢城是否发送上车提醒为 ${Notify818}...\n"
    perl -i -pe "s|let jdNotify = .+;|let jdNotify = ${Notify818};|" ${File818}
  fi
}


################################## 修改lxk0301大佬js文件的函数汇总 ##################################
function Change_ALL {
  Change_Cookie
  Change_Token
  Change_BeanSignStop
  Change_FruitShareCodes
  Change_PetShareCodes
  Change_PlantBeanShareCodes
  Change_coinToBeans
  Change_NotifyBlueCoin
  Change_superMarketUpgrade
  Change_businessCircleJump
  Change_drawLotteryFlag
  Change_NotifyFruit
  Change_jdFruitBeanCard
  Change_joyFeedCount
  Change_joyRewardName
  Change_NotifyJoyReward
  Change_NotifyJoySteal
  Change_NotifyJoy
  Change_joyRunFlag
  Change_jdJoyHelpFeed
  Change_jdJoyStealCoin
  Change_NotifyPet
  Change_NotifyDreamFactory
  Change_Unsubscribe
  # Change_Notify818
}


################################## 检测定时任务是否有变化 ##################################
## 此函数会在Log文件夹下生成四个文件，分别为：
## shell.list   shell文件夹下用来跑js文件的以“jd_”开头的所有 .sh 文件清单（去掉后缀.sh）
## js.list      scripts/docker/crontab_list.sh文件中用来运行js脚本的清单（去掉后缀.js，非运行脚本的不会包括在内）
## js-add.list  如果 scripts/docker/crontab_list.sh 增加了定时任务，这个文件内容将不为空
## js-drop.list 如果 scripts/docker/crontab_list.sh 删除了定时任务，这个文件内容将不为空
function Cron_Different {
  ls ${ShellDir} | grep -E "jd_.+\.sh" | perl -pe "s|\.sh||" > ${ListShell}
  cat ${ScriptsDir}/docker/crontab_list.sh | grep -E "jd_.+\.js" | perl -pe "s|.+(jd_.+)\.js.+|\1|" > ${ListJs}
  grep -v -f ${ListShell} ${ListJs} > ${ListJsAdd}
  grep -v -f ${ListJs} ${ListShell} > ${ListJsDrop}
}


################################## 设置环境变量：每日签到的通知形式 ##################################
## 要在检测并增删定时任务以后再运行
function Set_NotifyBeanSign {
  case ${NotifyBeanSign} in
    0)
      echo -e "设置每日签到的通知形式为 关闭通知，仅在运行 shell 脚本时有效，直接运行 js 脚本无效...\n"
      for file in ${ListShellDir}
      do
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_STOP_NOTIFY=).*$|\1true|" ${file}
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_NOTIFY_SIMPLE=).*$|# \1|" ${file}
      done
      ;;
    1)
      echo -e "设置每日签到的通知形式为 简洁通知，仅在运行 shell 脚本时有效，直接运行 js 脚本无效...\n"
      for file in ${ListShellDir}
      do
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_STOP_NOTIFY=).*$|# \1|" ${file}
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_NOTIFY_SIMPLE=).*$|\1true|" ${file}
      done
      ;;
    *)
      echo -e "每日签到的通知形式保持默认为 原始通知...\n"
      for file in ${ListShellDir}
      do
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_STOP_NOTIFY=).*$|# \1|" ${file}
        perl -i -pe "s|^.*(export JD_BEAN_SIGN_NOTIFY_SIMPLE=).*$|# \1|" ${file}
      done
      ;;
  esac
}


################################## 设置环境变量：User-Agent ##################################
## 要在检测并增删定时任务以后再运行
function Set_UserAgent {
  if [ -n "${UserAgent}" ]
  then
    echo -e "设置User-Agent为 ${UserAgent}\n\n仅在运行 shell 脚本时有效，直接运行 js 脚本无效...\n"
    for file in ${ListShellDir}
    do
      perl -i -pe "s|^.*(export JD_USER_AGENT=).*$|\1\"${UserAgent}\"|" ${file}
    done
  else
    for file in ${ListShellDir}
    do
      perl -i -pe "s|^.*(export JD_USER_AGENT=).*$|# \1|" ${file}
    done
  fi
}


################################## wget更新额外的js脚本 ##################################
## 额外的脚本
function Update_ExtraJs {
  echo -e "-------------------------------------------------------------------\n"
  echo -e "开始更新额外的js脚本：${JsList2}\n"
  echo -e "来源：${ScriptsURL2}\n"
  for js in ${JsList2}
  do
    [ -f "${ScriptsDir}/${js}.js.new" ] && rm -f "${ScriptsDir}/${js}.js.new"
    wget -q --no-check-certificate ${ScriptsURL2Raw}${js}.js -O ${ScriptsDir}/${js}.js.new
    if [ -s "${ScriptsDir}/${js}.js.new" ]
    then
      mv -f ${ScriptsDir}/${js}.js.new ${ScriptsDir}/${js}.js
      echo -e "${js}.js：更新成功...\n"
    else
      echo -e "${js}.js：更新失败，请检查网络是否可以访问Github的RAW文件，如无法访问，建议禁用额外的js脚本功能...\n"
    fi
  done
}


################################## 替换东东工厂互助码 ##################################
## 额外的脚本
function Change_FactoryShareCodes {
  ForOtherFactoryALL=""
  echo -e "${FileFactory}: 替换东东工厂互助码...\n"
  im=1
  while [ ${im} -le ${UserSum} ]
  do
    Temp5=ForOtherFactory${im}
    eval ForOtherFactoryTemp=$(echo \$${Temp5})
    ForOtherFactoryALL="${ForOtherFactoryALL}\\n        '${ForOtherFactoryTemp}',"
    let im++
  done
  perl -0777 -i -pe "s|(.+sharecodes = \[)\n(.+\n){2}(.+\];)|\1${ForOtherFactoryALL}\n\3|" ${FileFactory}
}


################################## 修改东东工厂是否自动注入电量 ##################################
## 额外的脚本
function Change_AutoAddPower {
  if [ "${AutoAddPower}" = "true" ] || [ "${AutoAddPower}" = "false" ]; then
    echo -e "${FileFactory}：修改东东工厂是否自动注入电量为：${AutoAddPower}..."
    perl -i -pe "s|autoAdd = .+;|autoAdd = ${AutoAddPower};|" ${FileFactory}
  fi
}


################################## 复制额外的js脚本对应的ash脚本并增加定时任务 ##################################
## 额外的脚本
function Copy_ExtraAsh {
  if [ -f ${FileJdSample} ]
  then
    JdShSample=$(cat ${FileJdSample})
    for js in ${JsList2}
    do
      [ ! -d "${LogDir}/${js}" ] && mkdir -p ${LogDir}/${js}

      if [ ! -f "${ShellDir}/${js}.ash" ] || [[ "${JdShSample}" != "$(cat ${ShellDir}/${js}.ash)" ]]; then
        cp -fv "${FileJdSample}" "${ShellDir}/${js}.ash"
      fi

      [ ! -x "${ShellDir}/${js}.ash" ] && chmod +x "${ShellDir}/${js}.ash"

      if [[ -z $(grep "${js}\.ash" ${ListCron}) ]]; then
        cat ${ShellDir}/crontab.list.sample | grep "${js}\.ash" | perl -pe "s|/root/shell|${ShellDir}|" >> ${ListCron}
        crontab ${ListCron}
      fi
    done
  else
    echo -e "${FileJdSample} 文件不存在，可能是shell脚本克隆不正常...\n未能添加额外的定时任务，请自行添加...\n"
  fi
}


################################## git更新shell脚本 ##################################
function Git_PullShell {
  echo -e "更新shell脚本，原地址：${ShellURL}\n"
  git fetch --all
  git reset --hard origin/main
  git pull
  if [ $? -eq 0 ]
  then
    echo -e "\nshell脚本更新完成...\n"
  else
    echo -e "\nshell脚本更新失败，请检查原因后再次运行git_pull.sh，或等待定时任务自动再次运行git_pull.sh...\n"
  fi
}


################################## npm install 子程序 ##################################
function NpmInstallSub {
  if [ -n "${isTermux}" ]
  then
    npm install --no-bin-links || npm install --no-bin-links --registry=https://registry.npm.taobao.org
  else
    npm install || npm install --registry=https://registry.npm.taobao.org
  fi
}


################################## 调用各函数来修改为设定值 ##################################
## 仅包括修改 lxk0301 大佬的 js 文件的相关函数，不包括设置临时环境变量
cd ${ScriptsDir}
Detect_VerJdShell
Detect_UserSum
if [ $? -eq 0 ]; then
  PackageListOld=$(cat package.json)
  Git_PullScripts
  GitPullExitStatus=$?
fi

if [ ${GitPullExitStatus} -eq 0 ]
then
  echo -e "js脚本更新完成，开始替换信息，并检测定时任务变化情况...\n"
  Change_ALL
  Cron_Different
else
  echo -e "js脚本更新失败，请检查原因或再次运行git_pull.sh...\n为保证js脚本在更新失败时能够继续运行，仍然替换信息，但不再检测定时任务是否有变化...\n"
  Change_ALL
fi


################################## 输出是否有新的定时任务 ##################################
if [ ${GitPullExitStatus} -eq 0 ] && [ -s ${ListJsAdd} ]; then
  echo -e "检测到有新的定时任务：\n"
  cat ${ListJsAdd}
  echo
fi


################################## 输出是否有失效的定时任务 ##################################
if [ ${GitPullExitStatus} -eq 0 ] && [ -s ${ListJsDrop} ]; then
  echo -e "检测到有失效的定时任务：\n"
  cat ${ListJsDrop}
  echo
fi
  

################################## 自动删除失效的脚本与定时任务 ##################################
## 如果检测到某个定时任务在 scripts/docker/crontab_list.sh 中已删除，那么在本地也删除对应的shell脚本与定时任务
## 此功能仅在 AutoDelCron 设置为 true 时生效
if [ ${GitPullExitStatus} -eq 0 ] && [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
  echo -e "开始尝试自动删除定时任务如下：\n"
  cat ${ListJsDrop}
  echo
  for Cron in $(cat ${ListJsDrop})
  do
    perl -i -ne "{print unless /\/${Cron}\./}" ${ListCron}
    rm -f "${ShellDir}/${Cron}.sh"
  done
  crontab ${ListCron}
  echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单如下：\n"
  crontab -l
  echo
fi


################################## 自动增加新的定时任务 ##################################
## 如果检测到 scripts/docker/crontab_list.sh 中增加新的定时任务，那么在本地也增加
## 此功能仅在 AutoAddCron 设置为 true 时生效
## 本功能生效时，会自动从 scripts/docker/crontab_list.sh 文件新增加的任务中读取时间，该时间为北京时间
if [ ${GitPullExitStatus} -eq 0 ] && [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
  echo -e "开始尝试自动添加定时任务如下：\n"
  cat ${ListJsAdd}
  echo
  JsAdd=$(cat ${ListJsAdd})
  if [ -f ${FileJdSample} ]
  then
    for Cron in ${JsAdd}
    do
      grep -E "\/${Cron}\." "${ScriptsDir}/docker/crontab_list.sh" | perl -pe "s|(^.+)node /scripts(/jd_.+)\.js.+|\1${ShellDir}\2\.sh|"  >> ${ListCron}
    done
    if [ $? -eq 0 ]
    then
      for Cron in ${JsAdd}
      do
        cp -fv "${FileJdSample}" "${ShellDir}/${Cron}.sh"
        chmod +x "${ShellDir}/${Cron}.sh"
      done
      crontab ${ListCron}
      echo -e "成功添加新的定时任务，当前的定时任务清单如下：\n"
      crontab -l
      echo
    else
      echo -e "未能添加新的定时任务，请自行添加...\n"
    fi
  else
    echo -e "${FileJdSample} 文件不存在，可能是shell脚本克隆不正常...\n未能成功添加新的定时任务，请自行添加...\n"
  fi
fi


################################## 设置临时环境变量 ##################################
## 设置临时环境变量要在检测并增删定时任务以后运行
## 仅在运行${ShellDir}下的jd_xxx.sh时生效，运行${ScriptsDir}下的jd_xxx.js无效
if [ ${GitPullExitStatus} -eq 0 ]; then
  Set_NotifyBeanSign
  Set_UserAgent
fi


################################## 额外的js脚本相关程序 ##################################
if [ "${EnableExtraJs}" = "true" ]; then
  cd ${ScriptsDir}
  
  ## 仅列出需要修改信息的名称
  FileFactory=jd_factory.js

  ## 清单
  JsList2="jd_factory jd_paopao"

  ## 来源
  ScriptsURL2="https://github.com/799953468/Quantumult-X"
  ScriptsURL2Raw="https://raw.githubusercontent.com/799953468/Quantumult-X/master/Scripts/JD/"
  
  Update_ExtraJs
  Change_FactoryShareCodes
  Change_AutoAddPower
  Copy_ExtraAsh
fi


################################## npm install ##################################
if [ ${GitPullExitStatus} -eq 0 ]; then
  cd ${ScriptsDir}
  isTermux=$(echo ${ANDROID_RUNTIME_ROOT})
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到 ${ScriptsDir}/package.json 内容有变化，再次运行 npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${ScriptsDir}/node_modules
    fi
    echo
  fi
  if [ ! -d ${ScriptsDir}/node_modules ]; then
    echo -e "运行npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n请进入 ${ScriptsDir} 目录后手动运行 npm install...\n"
      rm -rf ${ScriptsDir}/node_modules
      exit 1
    fi
  fi
fi


################################## 更新shell脚本 ##################################
if [ $? -eq 0 ]; then
  cd ${ShellDir}
  echo -e "-------------------------------------------------------------------\n"
  Git_PullShell
fi
