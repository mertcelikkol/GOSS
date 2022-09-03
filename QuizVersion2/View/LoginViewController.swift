//
//  LoginViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 30.07.2022.
//

import UIKit
import Firebase
import CryptoKit
import AuthenticationServices
import AudioToolbox
import GoogleSignIn

class LoginViewController: UIViewController,ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // Elemanların Tanımlanması
    
    // Sign-In Elements
    
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var userEmailInput: UITextField!
    @IBOutlet weak var userPasswordText: UITextField!
    @IBOutlet weak var girisYapButton: UIButton!
    
    // Sign-Up Elements
    
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var memberNameText: UITextField!
    @IBOutlet weak var memberEmailText: UITextField!
    @IBOutlet weak var memberPasswordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    // Degistirme Elements
    @IBOutlet weak var bottomText: UITextView!
    var control : Bool = true
    
    
    // Parametrelerin Tanımlanması
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    let ekranGenisligi = UIScreen.main.bounds.width

    override func viewDidLoad() {
        super.viewDidLoad()
        gunduzMod()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.textFieldAyarlamalari()
            self.flipStart()
            self.bottomClickConfig()
            self.tiklamaOlaylari()
            self.klavyeKapat()
            
            // Sign In Apple Function Call Back
            self.setupSignInWithAppleButton()
        }
        
    }
    

    func textFieldAyarlamalari(){
        userPasswordText.isSecureTextEntry = true
        userEmailInput.keyboardType = .emailAddress
        userEmailInput.autocorrectionType = .no
        cornerRadius()
    }
    
    func cornerRadius(){
        signInView.layer.cornerRadius = 10
        signUpView.layer.cornerRadius = 10
        girisYapButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        bottomText.layer.cornerRadius = 10
    }
    
    
    func bottomClickConfig(){
        bottomText.isUserInteractionEnabled = true
        let flipGesture = UITapGestureRecognizer(target: self, action: #selector(flipStart))
        bottomText.addGestureRecognizer(flipGesture)
    }
    
    func tiklamaOlaylari(){
        
        // Sign In
        
        let signInGesture = UITapGestureRecognizer(target: self, action: #selector(signInClicked))
        girisYapButton.addGestureRecognizer(signInGesture)
        
        // Sign Up
        
        let signUpGesture = UITapGestureRecognizer(target: self, action: #selector(signUpClicked))
        signUpButton.addGestureRecognizer(signUpGesture)
        
    }
    
    func setupSignInWithAppleButton(){
        // let signInWithAppleButton = ASAuthorizationAppleIDButton()
        let signInWithAppleButton = UIButton()
        signInWithAppleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        signInWithAppleButton.frame = CGRect(x: girisYapButton.frame.origin.x, y: girisYapButton.frame.origin.y + 55, width: girisYapButton.frame.size.width - 2, height: girisYapButton.frame.size.height)
        signInWithAppleButton.setTitle(" Apple ile Giriş Yap", for: .normal)
        signInWithAppleButton.layer.cornerRadius = 10
        signInWithAppleButton.backgroundColor = UIColor.black
        signInWithAppleButton.titleLabel?.textColor = UIColor.white
        signInWithAppleButton.tintColor = UIColor.white
        self.signInView.addSubview(signInWithAppleButton)
        
        // let signUpWithAppleButton = ASAuthorizationAppleIDButton()
        let signUpWithAppleButton = UIButton()
        signUpWithAppleButton.frame = CGRect(x: userEmailInput.frame.origin.x , y: girisYapButton.frame.origin.y + 55, width: girisYapButton.frame.size.width , height: girisYapButton.frame.size.height)
        signUpWithAppleButton.backgroundColor = UIColor.black
        signUpWithAppleButton.titleLabel?.textColor = UIColor.white
        signUpWithAppleButton.tintColor = UIColor.white
        signUpWithAppleButton.setTitle(" Apple ile Kayıt Ol", for: .normal)
        signUpWithAppleButton.layer.cornerRadius = 10
        signUpWithAppleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        self.signUpView.addSubview(signUpWithAppleButton)
        
        
        
        // Google Butonları START
        
        let googleSignInButton = UIButton()
        googleSignInButton.frame = CGRect(x: userEmailInput.frame.origin.x , y: signInWithAppleButton.frame.origin.y + 44, width: signInWithAppleButton.frame.size.width , height: signInWithAppleButton.frame.size.height)
        googleSignInButton.setTitle("Google ile Giriş Yap", for: .normal)
        googleSignInButton.layer.cornerRadius = 10
        googleSignInButton.backgroundColor = UIColor.black
        googleSignInButton.titleLabel?.textColor = UIColor.white
        googleSignInButton.tintColor = UIColor.white
        googleSignInButton.addTarget(self, action: #selector(googleSignUpAction), for: .allTouchEvents)
        self.signInView.addSubview(googleSignInButton)
        
        let googleSignUpButton = UIButton()
        googleSignUpButton.frame = CGRect(x: userEmailInput.frame.origin.x , y: signUpWithAppleButton.frame.origin.y + 44, width: signUpWithAppleButton.frame.size.width , height: signUpWithAppleButton.frame.size.height)
        googleSignUpButton.setTitle("Google ile Kayıt Ol", for: .normal)
        googleSignUpButton.layer.cornerRadius = 10
        googleSignUpButton.backgroundColor = UIColor.black
        googleSignUpButton.titleLabel?.textColor = UIColor.white
        googleSignUpButton.tintColor = UIColor.white
        googleSignUpButton.addTarget(self, action: #selector(googleSignInAction), for: .allTouchEvents)
        self.signUpView.addSubview(googleSignUpButton)
        // Google Butonları END
        
        
    }
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    // Complete the Sign In Transaction
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
              guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
              }
              // Initialize a Firebase credential.
              let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                        idToken: idTokenString,
                                                        rawNonce: nonce)
              // Sign in with Firebase.
              Auth.auth().signIn(with: credential) { (authResult, error) in
                  if error == nil {
                      if let authResult = authResult {
                          let uid = authResult.user.uid
                          let mail = authResult.user.email
                          let memberType = "standart"
                          var userName = mail
                          if let isim = appleIDCredential.fullName?.givenName {
                              userName = isim
                          }
                          let newUser = [
                              "mail" : mail!,
                              "memberType" : memberType,
                              "password" : uid,
                              "uid" : uid,
                              "userName" : userName!
                          ] as [String:Any]
                          let database = Database.database()
                          database.reference(withPath: "user").child(uid).setValue(newUser) { Error, dataRef in
                              if error == nil {
                                  self.performSegue(withIdentifier: "LoginToVievController", sender: nil)
                              } else {
                                  self.alarmVer(baslik: "Error", mesaj: error?.localizedDescription ?? "İnternet bağlantınızdan emin olun")
                              }
                          }
                      }
                      
                  } else {
                      self.alarmVer(baslik: "Error", mesaj: error?.localizedDescription ?? "Apple Kimliğiniz Doğrulanamadı")
                      
                  }
                
              }
            }
    }
    // Error the Sign In Transaction
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir Error oluştu. Daha sonra tekrar deneyin.")
    }
    // Delegate Requirement
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    // Sign In with Apple END
    
    
    @objc func flipStart(){
        var metin : String = ""
        if control {
            metin = "Zaten üye misin?"
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            self.signInView.isHidden = false
            self.signUpView.isHidden = true
        } else {
            metin = "Kayıtlı değil misin?"
            
            UIView.animate(withDuration: 200, delay: 0, options: .transitionFlipFromRight) {
                
            } completion: { aksiyon in
                if aksiyon {
                    self.signUpView.isHidden = false
                    self.signInView.isHidden = true
                } else {
                    
                }
            }
        }
        
        control = !control
        bottomText.text = metin
    }
    
    @objc func signInClicked(){
        let auth = Auth.auth()
        if userEmailInput.text != "" {
            let email = userEmailInput.text ?? ""
            if userPasswordText.text != "" {
                let password = userPasswordText.text ?? ""
                auth.signIn(withEmail: email, password: password) { result, error in
                    if error == nil {
                        self.performSegue(withIdentifier: "LoginToVievController", sender: nil)
                    } else {
                        self.alarmVer(baslik: "Hata", mesaj: error?.localizedDescription ?? "E-mail ve şifre bilgilerinizden emin olun.")
                    }
                }
            } else {
                self.alarmVer(baslik: "Hata", mesaj: "Lütfen şifrenizi girin")
            }
        } else {
            self.alarmVer(baslik: "Hata", mesaj: "Lütfen e-mail adresinizi girin.")
        }
    }
    
    @objc func signUpClicked(){
        let auth = Auth.auth()
        let database = Database.database()
        if memberNameText.text != "" {
            let userName = memberNameText.text ?? ""
            if memberEmailText.text != "" {
                let mail = memberEmailText.text ?? ""
                if memberPasswordText.text != "" {
                    let password = memberPasswordText.text ?? ""
                    auth.createUser(withEmail: mail, password: password) { result, error in
                        if error == nil {
                            if let result = result {
                                let uid = result.user.uid
                                let memberType = "standart"
                                let member = [
                                    "mail" : mail,
                                    "password" : password,
                                    "memberType" : memberType,
                                    "uid" : uid,
                                    "userName" : userName
                                ] as [String : Any]
                                database.reference(withPath: "user").child("uid").setValue(member) { error, sadet in
                                    self.performSegue(withIdentifier: "LoginToVievController", sender: nil)
                                }
                            } else {
                                self.alarmVer(baslik: "Hata", mesaj: "İnternet bağlantınızdan emin olun.")
                            }
                        } else {
                            if let error = error {
                                self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                            } else {
                                self.alarmVer(baslik: "Hata", mesaj: "Kayıt işlemi sırasında beklenmedik bir hata oluştu. Lütfen internet bağlantınızdan emin olun.")
                            }
                        }
                    }
                } else {
                    self.alarmVer(baslik: "Hata", mesaj: "Lütfen şifrenizi girin.")
                }
            } else {
                self.alarmVer(baslik: "Hata", mesaj: "Lütfen e-mail adresinizi girin.")
            }
        } else {
            self.alarmVer(baslik: "Hata", mesaj: "Lütfen kullanıcı adınızı girin.")
        }
    }
    
    @objc func googleSignInAction(){
        
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            return
        }
        print("CLIENT ID : \(clientId)")
        // Create Google Sign In configuration object
        
        let config = GIDConfiguration(clientID: clientId)
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                return
              }

              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)

            print("CREDENTIAL : \(credential)")
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                print("DURAK 1")
                var displayNameString = ""
                if let error = error {
                    print("DURAK 2")
                  let authError = error as NSError
                  if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    
                    for tmpFactorInfo in resolver.hints {
                      displayNameString += tmpFactorInfo.displayName ?? ""
                      displayNameString += " "
                    }
                    self.showTextInputPrompt(
                      withMessage: "Select factor to sign in\n\(displayNameString)",
                      completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                          if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                          }
                        }
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                             multiFactorSession: resolver
                                               .session) { verificationID, error in
                            if error != nil {
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
                            } else {
                              self.showTextInputPrompt(
                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                completionBlock: { userPressedOK, verificationCode in
                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                    .credential(withVerificationID: verificationID!,
                                                verificationCode: verificationCode!)
                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                    .assertion(with: credential!)
                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                                    if error != nil {
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
                                    } else {
                                      self.navigationController?.popViewController(animated: true)
                                    }
                                  }
                                }
                              )
                            }
                          }
                      }
                    )
                  } else {
                      print("DURAK 3")
                      self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                    return
                  }
                  // ...
                  return
                }
                print("DURAK 4")
                // User is signed in
                // ...
                if let result = authResult {
                    let uid = result.user.uid
                    let mail = result.user.email
                    let userName = result.user.displayName
                    let memberType = "standart"
                    let newUser = [
                        "mail" : mail ?? "",
                        "memberType" : memberType,
                        "password" : uid,
                        "uid" : uid,
                        "userName" : userName ?? ""
                    ] as [String:Any]
                    let database = Database.database()
                    database.reference(withPath: "user").child(uid).setValue(newUser) { Error, dataRef in
                        if error == nil {
                            self.goCategory()
                        } else {
                            self.alarmVer(baslik: "Error", mesaj: error?.localizedDescription ?? "İnternet bağlantınızdan emin olun")
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    @objc func googleSignUpAction(){
        
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object
        
        let config = GIDConfiguration(clientID: clientId)
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self, hint: "Google'a Yönlendiriliyorsunuz") { user, error in
            if let error = error {
                self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                return
              }
            print("CASE 3")
              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)

            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                print("CASE 4")
                if let error = error {
                    self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                }
                print("CASE 5")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginToVievController", sender: nil)
                }
            }
        }
        
    }
    
}
