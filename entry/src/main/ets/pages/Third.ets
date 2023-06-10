// @ts-nocheck
/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import prompt from '@system.prompt';
import UdpClient from '../Utils/UdpClient';
import File from '@system.file';


@Entry
@Component
struct Third {
  private localIp: string = router.getParams().localIp
  private serverIp: string = router.getParams().serverIp
  private udpClient: UdpClient = null
  @State private image: PixelMap = null
  private options = {
    alphaType: 0,                     // 透明度
    editable: false,                  // 是否可编辑
    PixelMapFormat: 3,                // 像素格式
    scaleMode: 1,                     // 缩略值
    size: {height: 550, width: 380}
  }
  private showCnt: number = 0
  private receiveCnt: number = 0
  private context: Context = null
  private filesDir: string = null
  @State private state: number = 0
  private file: File = null
  private prepareOpeningFile(){
    // 新建并打开并截断文件
    const filePath = this.filesDir + '/frame' + (this.receiveCnt++) + '.jpg';
    if(this.receiveCnt >= 25) this.receiveCnt = 0;
    try {
      this.file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.truncate(this.file.fd);
    }catch(error) {
      prompt.showToast({
        message: `${error}`
      })
    }
  }
  private showPicture(){
    const filePath = this.context.filesDir + '/frame' + (this.showCnt++) + '.jpg';
    if(this.showCnt >= 25) this.showCnt = 0;

    const imageSource = image.createImageSource(filePath);
    try {
      imageSource.createPixelMap(this.options, (err, pixelmap) => {
        this.image = pixelmap;
      })
      imageSource.release()
    }catch(error) {
      prompt.showToast({
        message: `${error}`
      })
    }
  }

  onPageShow() {
    this.context = getContext(this);
    // 获取resourceManager资源管理器
    this.resourceMgr = this.context.resourceManager;
    // 获取应用文件路径
    this.filesDir = this.context.filesDir;

    this.udpClient = new UdpClient(this.localIp, this.serverIp)
    this.udpClient.bindUdp(8964)
    this.udpClient.onMessage((dataView) => {
      let writeLen = 0;
      const buffer = new Uint8Array(dataView.buffer);
      if(buffer[buffer.byteLength-2] === 'o'.charCodeAt(0) && buffer[buffer.byteLength-1] === 'k'.charCodeAt(0)){
        if(this.state === 0){
          this.prepareOpeningFile();
        }
        writeLen = fs.writeSync(this.file.fd, buffer.buffer, {length: buffer.buffer.byteLength-2});
        fs.closeSync(this.file);
        this.state = 0;
      }else if(buffer[buffer.byteLength-2] === 'g'.charCodeAt(0) && buffer[buffer.byteLength-1] === 'o'.charCodeAt(0)){
        if(this.state === 0){
         this.state = 1;
          this.prepareOpeningFile();
        }
        writeLen = fs.writeSync(this.file.fd, buffer.buffer, {length: buffer.buffer.byteLength-2});
      }else {
        prompt.showToast({
          message: `udp buffer data error ocurred`
        })
      }
      this.showPicture();

      prompt.showToast({
        message: `${this.filesDir}: ${writeLen}`
      })
    })
  }

  aboutToDisappear() {
    this.udpClient.closeUdp()
  }

  build() {
    Column() {
      Title({ title: `对端ip: ${this.serverIp}` })

      Row() {
        Image(this.image)
          .height(this.options.size.height)
          .width(this.options.size.width)
      }
    }.height("100%")
    .width("100%")
  }
}

@Component
struct Title {
  private title: string

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Text(this.title).fontSize(20).fontColor("#fdfdfd")
    }.height(60).backgroundColor("#333534")
  }
}