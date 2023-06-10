// Second.ets
// 导入socket模块
import router from '@ohos.router';
import prompt from '@system.prompt';
import wifi from '@ohos.wifi'
import { resolveIP } from '../Utils/SocketUtil'


let ipInfo=wifi.getIpInfo();
let localIp = resolveIP(ipInfo.ipAddress);
let serverIp = resolveIP(ipInfo.serverIp);

@Entry
@Component
struct Second {

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Row() {
        Text('本地IP: ').fontSize(25).width('30%').fontWeight(FontWeight.Bold)

        Text(localIp)
          .fontSize(25)
      }
      .width('80%')

      Row() {
        Text('路由IP: ').fontSize(25).width('30%').fontWeight(FontWeight.Bold)

        Text(serverIp)
          .fontSize(25)
      }
      .width('80%')

      Text('确定')
        .height(50)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .borderRadius(20)
        .fontSize(25)
        .width('80%')
        .margin({ top: 45 })
        .backgroundColor('#1890ff')
        .onClick(() => {
          if (localIp === '' || localIp === '0.0.0.0') {
            prompt.showToast({
              message: '请检查网络环境'
            })
            return
          }

          router.pushUrl({
            url: 'pages/Third',
            params: { localIp: localIp, serverIp: serverIp}
          })
        })
    }
    .width('100%')
    .height('100%')
  }
}
