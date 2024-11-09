## Swift-JavaScript-Injector
| Extension JavaScript Kod Calistirma&Kaydetme | Onerilen JavaScript Kodu Calistirma | Canli JavaScript Kodu Yazimi |
|---------|---------|---------|
| <img src="https://github.com/user-attachments/assets/6875008f-690c-41cf-ae88-ad5d3e61a19a" alt="Video 1" width="300"/> | <img src="https://github.com/user-attachments/assets/5e86a67f-e95e-4ae4-9374-ddaf80849291" alt="Video 2" width="300"/> | <img src="https://github.com/user-attachments/assets/7f0a3e5b-ab21-44fe-ae62-d64d57877792" alt="Video 3" width="300"/> |


 <details>
    <summary><h2>Uygulamanın Amacı</h2></summary>
    Proje Amacı
   Bu projede, bir iOS Eylem Uzantısı uygulaması olarak geliştirilmiş. Amacı, kullanıcının bulunduğu web sayfasında JavaScript çalıştırmasına olanak tanımak. Kullanıcı, uygulamanın arayüzünden JavaScript kodu girebilir ve bu kodu sayfada çalıştırabilir. Ek olarak, kullanıcı belirli bir site için yazdığı JavaScript kodunu kaydedebilir ve siteye tekrar girdiğinde otomatik olarak bu kodun yüklenmesini sağlayabilir. Şimdi kodun her bölümünün işlevini açıklayalım:
  </details>  



  <details>
    <summary><h2>Action.js</h2></summary>
    Kod, şu iki temel işlevi gerçekleştirir:
    Sayfanın Bilgilerini Almak: Sayfanın URL'sini ve başlığını (title) alır ve bu bilgileri, iOS tarafında kullanılmak üzere gönderir.
    Özel JavaScript Kodunu Çalıştırmak: Kullanıcının belirlediği JavaScript kodunu, ilgili web sayfası üzerinde çalıştırır. Bu işlem, kullanıcının sayfa üzerinde dinamik olarak özel işlemler yapmasına imkan tanır
    run fonksiyonu, uzantı çalıştırıldığında aktif hale gelir. Bu fonksiyonun görevi:
    Tarayıcıdaki aktif sayfanın URL ve başlık bilgilerini almak.
    Bu bilgileri bir sözlük/dictionary olarak iOS uzantısına iletmek. parameters.completionFunction bu verileri göndermek için kullanılır.
    Bu veriler daha sonra uzantıda görüntüleme veya başka işlemler için kullanılabilir
    finalize fonksiyonu, kullanıcının tanımladığı özel JavaScript kodunu çalıştırmak için kullanılır:
    customJavaScript adlı bir parametre bekler. Bu, uzantı arayüzünden alınan özel JavaScript kodudur.
    eval(customJavaScript) ifadesi ile bu kod, web sayfası üzerinde çalıştırılır.
    eval fonksiyonu, dinamik olarak JavaScript kodu çalıştırır; burada dikkat edilmesi gereken, kodun güvenilir bir kaynaktan alınması gerektiğidir, aksi takdirde güvenlik riskleri oluşabilir
    
    ```
       var Action = function() {};

     Action.prototype = {

     run: function(parameters) {
    parameters.completionFunction({"URL": document.URL, "title": document.title });
    },

    finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
    }

    };

    var ExtensionPreprocessingJS = new Action

    ```
  </details> 

  <details>
    <summary><h2>viewDidLoad Fonksiyonu</h2></summary>
    viewDidLoad: Uygulamanın yüklendiği anda çağrılan fonksiyondur.
    Sağ üst köşeye "done" (tamamla) butonu ve "save" (kaydet) butonu eklenmiştir. "done" butonu JavaScript kodunu çalıştırır, "save" butonu ise kullanıcının girdiği JavaScript kodunu kaydeder.
    Sol üst köşeye ise rastgele kod önerileri sunan bir buton eklenmiştir.
    NotificationCenter: Klavyenin ekranı kapatmaması için bir gözlemci eklenmiştir. Klavye açıldığında veya kapandığında adjustForKeyboard fonksiyonu çağrılır.
    extensionContext: Kullanıcının bulunduğu sayfanın başlığı (pageTitle) ve URL'si (pageUrl) alınır ve title alanına atanır.
    loadSavedCode(): Kaydedilmiş bir JavaScript kodu varsa script alanına yükler.

    
    ```
      override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    
    let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCode))
    navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItem!, saveButton]
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(rastgeleCode))
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
        if let itemProvider = inputItem.attachments?.first {
            itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                guard let itemDictionary = dict as? NSDictionary else { return }
                guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                
                
                self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                self?.pageUrl = javaScriptValues["URL"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self?.title = self?.pageTitle
                    self?.loadSavedCode()
                }
            }
        }
    }
    }



    ```
  </details> 

  <details>
    <summary><h2>loadSavedCode Fonksiyonu</h2></summary>
    loadSavedCode(): Bu fonksiyon, UserDefaults'tan geçerli URL ile ilişkili kaydedilmiş JavaScript kodunu alır ve script alanına yükler
    
    ```
        func loadSavedCode() {
    if let savedCode = UserDefaults.standard.string(forKey: pageUrl) {
        script.text = savedCode
    }
    }




    
    ```
  </details> 


  <details>
    <summary><h2>saveCode Fonksiyonu</h2></summary>
    saveCode(): Bu fonksiyon, pageUrl boş değilse kullanıcının girdiği JavaScript kodunu UserDefaults'a kaydeder.
    Kayıt işlemi başarıyla tamamlandığında, kullanıcıya "Başarıyla Kaydedildi" mesajı gösterilir.
    
    ```

    @objc func saveCode() {
    guard !pageUrl.isEmpty else { return }
    UserDefaults.standard.set(script.text, forKey: pageUrl)
    
    let alert = UIAlertController(title: "Başarıyla Kaydedildi", message: "Kodunuz bu site için kaydedildi.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
    present(alert, animated: true)
    }



    ```
  </details> 

  <details>
    <summary><h2>done Fonksiyonu</h2></summary>
    done(): Bu fonksiyon, kullanıcının girdiği JavaScript kodunu alır ve uzantının içinde bulunduğu web sayfasında çalıştırmak için hazırlar.
    extensionContext?.completeRequest(): Kodun çalıştırılmasını sağlar ve uzantıyı kapatır.
    
    ```
            @IBAction func done() {
    let item = NSExtensionItem()
    let argument: NSDictionary = ["customJavaScript": script.text]
    let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument ]
    let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
    item.attachments = [customJavaScript]
    extensionContext?.completeRequest(returningItems: [item])
    }



    ```
  </details> 

  <details>
    <summary><h2>adjustForKeyboard Fonksiyonu</h2></summary>
    adjustForKeyboard(): Bu fonksiyon klavye açıldığında veya kapandığında metin kutusunun (script) görünürlüğünü ve kaydırma ayarlarını düzenler.
    
    ```
       @objc func adjustForKeyboard(notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification {
        script.contentInset = .zero
    } else {
        script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    script.scrollIndicatorInsets = script.contentInset
    let selectedRange = script.selectedRange
    script.scrollRangeToVisible(selectedRange)
    }




    ```
  </details> 
  <details>
    <summary><h2>rastgeleCode Fonksiyonu</h2></summary>
    rastgeleCode(): Kullanıcıya rastgele JavaScript kodu önerileri sunan bir fonksiyondur. Kullanıcı bu kodları seçerek script alanına otomatik olarak ekleyebilir.
    İki seçenek sunulur:
    "Sayfada Yavaşça Aşağı Kaydırma": Arka plan rengini sürekli değiştiren bir kod ekler.
    "Yavaş Yavaş Kaybolma Efekti": Sayfanın yavaş yavaş kaybolmasını sağlayan bir kod ekler.
    
    ```
       @objc func rastgeleCode(){
    let ac = UIAlertController(title: "Sizin icin Öneri", message: "Assagida rastegele onerilen JavaScript kodlariyla yapabilceklerinizi deneyimleyebilirsiniz", preferredStyle: .alert)
    
    ac.addAction(UIAlertAction(title: "Sayfada Yavaşça Aşağı Kaydırma", style: .default, handler: { action in
        self.script.text = "setInterval(() => { document.body.style.backgroundColor = \"#\" + Math.floor(Math.random()*16777215).toString(16); }, 1000);"
    }))
    
    ac.addAction(UIAlertAction(title: "Yavaş Yavaş Kaybolma Efekti", style: .default, handler: { action in
        self.script.text = """
                           var opacity = 1;
                         setInterval(() => {
                        if (opacity > 0) {
                          opacity -= 0.05;
                         document.body.style.opacity = opacity;
                           }
                        }, 100);
                       """
    }))
    
    present(ac, animated: true)
    }





    ```
  </details> 

<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Extension Gorunum</h4>
            <img src="https://github.com/user-attachments/assets/cbe2ef11-06b9-4a3d-be2f-7bee78de26ec" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Extension JavaScript Kodu yazma<</h4>
            <img src="https://github.com/user-attachments/assets/ada9b992-b29a-4a84-b6dc-2e33155483ab" style="width: 100%; height: auto;">
        </td>
              <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Extension JavaScript Kodu Kaydetme<</h4>
            <img src="https://github.com/user-attachments/assets/958424c0-cbcd-464e-b09c-8da3cb187cee" style="width: 100%; height: auto;">
        </td>
              <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Extension JavaScript Kod Onerisi<</h4>
            <img src="https://github.com/user-attachments/assets/7653a111-af0a-4a34-932d-7406279581ba" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 
