var http = require("http")
var defaultApi = "https://ethereum-rpc.publicnode.com"
class priceTracker {
    constructor(nodeUrl = defaultApi,stableCoinPreference = "USDT",preferedExchange = "PancakeSwap"){
        this.nodeUrl = nodeUrl
        this.stableCoinPreference = stableCoinPreference
        this.preferedExchange = preferedExchange
    }
    function getPairExchangeRate(coin1,coin2){
      if(preferedExchange=="PancakeSwap"){
        var thingy = post('{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0x10ED43C718714eb63d5aA57B78B54704E256024E","data"' +  + '}],"id":1}')
      }
    }
    function getFiatPrice(coin){

    }
}
function post_wrap(data,url,datatype){
  let receivingData = "";
  let stuff = new Object();
  let options = {
    hostname: isolateDomain(url),
    port: 80,
    method: "POST",
    path: isolatePath(url),
    Headers: {
      "Content-length": Buffer.byteLength(data),
      "Content-type": datatype,
      //user agent is firefox because firefox is based sigma gigachad
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    },
  };
  console.log(options[hostname]+"aaaaaa")
  return new Promise((resolve,reject)=>{let request = http.request(options,(res)=>{
    res.on(data, (chunk) => {
      receivingData = receivingData + chunk
    });
    res.on("end", () => {
      stuff[1] = res.statusCode
      stuff[2] = res.headers["content-type"]
      stuff[3] = receivingData
      resolve(stuff);
  });
  daRequest.on("error", (err) => {stuff[1] = NaN
                                  //identatiion getting silly
                                    resolve(stuff)
                                 })
                  });request.write(data);request.end();})
}

  async function post(data,url,datatype){
    dumb_shit = await await post_wrap(data,url,datatype)
    return dumb_shit
  }