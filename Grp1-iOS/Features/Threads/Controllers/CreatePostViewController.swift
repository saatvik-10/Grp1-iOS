
import UIKit


class CreatePostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    enum CreatePostMode {
        case newPost
        case editDraft
    }
    
    var mode: CreatePostMode = .newPost
    var apiDraft: APIThreadDraft?
    
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var imageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var addTopicTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var saveDraft: UIButton!
    
    let placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextViewPlaceholder()
        configureForMode()
       
        // Start with pill height visible, image hidden
               imageContainerHeight.constant = 50
               postImageView.isHidden = true
               removeImageButton.isHidden = true
               addImageButton.isHidden = false
        
        imageView.bringSubviewToFront(removeImageButton)
        setupKeyboardDismissal()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Management
    private func setupKeyboardDismissal() {
        // 1. Tap anywhere to dismiss — delegate allows it to fire even on UITextView
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        tap.cancelsTouchesInView = false
        tap.delegate = self              // ← critical: enables simultaneous recognition
        view.addGestureRecognizer(tap)
        
        // 2. Swipe-down gesture to dismiss keyboard
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(swipe)
        
        // 3. Delegate setup for return key dismissal on text fields
        titleTextField.delegate = self
        addTopicTextField.delegate = self
        
        // 4. Set return key types for better UX
        titleTextField.returnKeyType = .next
        addTopicTextField.returnKeyType = .done
    }
    
    // Allow our tap gesture to fire even when the touch lands on UITextView/UITextField
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc private func dismissKeyboardAction() {
        view.endEditing(true)
    }
    
    // Dismiss keyboard on Return/Done key for UITextFields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            addTopicTextField.becomeFirstResponder()  // move to tags field
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func didTapAddImage(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func didTapRemoveImage(_ sender: UIButton) {
        removeImage()
    }
    
    //
    
    @IBAction func didTapDrafts(_ sender: Any) {
        performSegue(withIdentifier: "Drafts", sender: nil)
    }
    
    @IBAction func didTapSaveDraft(_ sender: UIButton) {
        view.endEditing(true)
        print("🟡 didTapSaveDraft called")
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No authToken found in UserDefaults!")
            let alert = UIAlertController(title: "Not Logged In", message: "Please log in to save a draft.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        print("✅ Token found: \(token.prefix(20))...")
        
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = bodyTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        print("📝 Title: '\(title)', Body length: \(body.count)")
        
        if title.isEmpty || body.isEmpty {
            print("❌ Title and description cannot be empty!")
            let alert = UIAlertController(title: "Missing Fields", message: "Title and description cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let rawTags = addTopicTextField.text ?? ""
        let tags = rawTags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let imageData = postImageView.image?.jpegData(compressionQuality: 0.8)
        
        // Disable button to prevent double-tap
        saveDraft.isEnabled = false
        saveDraft.setTitle("Saving...", for: .normal)
        
        print("🚀 Sending draft to API — baseURL: \(APIService.shared.baseURL)")
        
        if let existingDraft = apiDraft {
            APIService.shared.updateDraft(
                draftId: existingDraft.id,
                title: title,
                description: body,
                tags: tags,
                imageData: imageData,
                imageFileName: imageData != nil ? "draft.jpg" : nil,
                token: token
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.saveDraft.isEnabled = true
                    self?.saveDraft.setTitle("Save Draft", for: .normal)
                    switch result {
                    case .success:
                        print("✅ Draft updated in DB!")
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("❌ Failed to update draft: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to update draft: \(error)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        } else {
            let payload = APICreateDraftRequest(
                title: title,
                description: body,
                tags: tags,
                threadId: nil,
                imageData: imageData,
                imageFileName: imageData != nil ? "draft.jpg" : nil
            )
            APIService.shared.saveDraft(payload: payload, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    self?.saveDraft.isEnabled = true
                    self?.saveDraft.setTitle("Save Draft", for: .normal)
                    switch result {
                    case .success:
                        print("✅ Draft saved to DB!")
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("❌ Failed to save draft: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Failed to save draft: \(error)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapPost(_ sender: UIButton) {
        view.endEditing(true)
        guard let title = titleTextField.text, !title.isEmpty,
              let body = bodyTextView.text, !body.isEmpty
        else { return }
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No auth token — user not logged in")
            return
        }
        let rawTags = addTopicTextField.text ?? ""
        let tags = rawTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Debug: print the JSON body
        let bodyDict: [String: Any] = [
            "title": title,
            "description": body,
            "tags": tags.isEmpty ? ["General"] : tags
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 JSON being sent:\n\(jsonString)")
        }
        
        postButton.isEnabled = false
        postButton.setTitle("Posting...", for: .normal)
        let payload = APICreateThreadRequest(
            title: title,
            description: body, // use "description" as per backend
            tags: tags.isEmpty ? ["General"] : tags,
            imageData: postImageView.image?.jpegData(compressionQuality: 0.8),
            imageFileName: postImageView.image != nil ? "thread.jpg" : nil
        )
        APIService.shared.createThread(
            payload: payload,
            token: token
        ) { [weak self] (result: Result<APIThread, APIError>) in
            DispatchQueue.main.async {
                self?.postButton.isEnabled = true
                self?.postButton.setTitle("Post", for: .normal)
                switch result {
                case .success:
                    print("✅ Thread posted to DB!")
                    
                    // If we were editing a draft, delete the draft now that it's published
                    if let draftId = self?.apiDraft?.id {
                        APIService.shared.deleteDraft(draftId: draftId, token: token) { deleteResult in
                            switch deleteResult {
                            case .success:
                                print("✅ Associated draft \(draftId) deleted successfully")
                            case .failure(let error):
                                print("⚠️ Failed to delete associated draft \(draftId): \(error)")
                            }
                        }
                    }
                    
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("❌ Failed to post thread: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to post. Try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    
    func setupUI() {
              bodyTextView.delegate = self
              bodyTextView.isScrollEnabled = true
       
              view.backgroundColor = UIColor(white: 249/255, alpha: 1)
              contentView.backgroundColor = .clear
       
              styleTitleField()
              styleTagsField()
              styleBodyView()
              styleImageZone()
            styleSaveDraftButton()
          }
       
          // MARK: - Title field
          private func styleTitleField() {
              titleTextField.borderStyle = .none
              titleTextField.font = .systemFont(ofSize: 20, weight: .medium)
              titleTextField.attributedPlaceholder = NSAttributedString(
                  string: "Title",
                  attributes: [.foregroundColor: UIColor.tertiaryLabel,
                               .font: UIFont.systemFont(ofSize: 20, weight: .medium)]
              )
              let divider = UIView()
              divider.translatesAutoresizingMaskIntoConstraints = false
              divider.backgroundColor = .systemGray5
              titleTextField.addSubview(divider)
              NSLayoutConstraint.activate([
                  divider.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
                  divider.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
                  divider.bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor),
                  divider.heightAnchor.constraint(equalToConstant: 0.5),
              ])
          }
       
          // MARK: - Tags field
          private func styleTagsField() {
              addTopicTextField.borderStyle = .none
              addTopicTextField.font = .systemFont(ofSize: 14)
              addTopicTextField.textColor = .label
              addTopicTextField.attributedPlaceholder = NSAttributedString(
                  string: "Add tags, separated by commas",
                  attributes: [.foregroundColor: UIColor.tertiaryLabel,
                               .font: UIFont.systemFont(ofSize: 14)]
              )
              addTopicTextField.backgroundColor = UIColor(white: 243/255, alpha: 1)
              addTopicTextField.layer.cornerRadius = 10
              addTopicTextField.layer.masksToBounds = true
              let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
              addTopicTextField.leftView = paddingView
              addTopicTextField.leftViewMode = .always
          }
       
          // MARK: - Body text view
          private func styleBodyView() {
              bodyTextView.font = .systemFont(ofSize: 15)
              bodyTextView.textColor = .label
              bodyTextView.backgroundColor = .white
              bodyTextView.layer.cornerRadius = 12
              bodyTextView.layer.borderWidth = 0.5
              bodyTextView.layer.borderColor = UIColor.systemGray4.cgColor
              bodyTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
          }
       
          // MARK: - Image zone
          private func styleImageZone() {
              // Container: rounded corners + clips so the image inherits them
              imageView.layer.cornerRadius = 12
              imageView.layer.borderWidth = 1
              imageView.layer.borderColor = UIColor.systemGray4.cgColor
              imageView.backgroundColor = UIColor(white: 246/255, alpha: 1)
              imageView.clipsToBounds = true          // ← image will be clipped to rounded corners
     
              // Add Image pill button
              var config = UIButton.Configuration.plain()
              config.image = UIImage(systemName: "photo")
              config.imagePlacement = .leading
              config.imagePadding = 6
              config.baseForegroundColor = .secondaryLabel
              config.attributedTitle = AttributedString("Add Image", attributes: AttributeContainer([
                  .font: UIFont.systemFont(ofSize: 14),
                  .foregroundColor: UIColor.secondaryLabel
              ]))
              addImageButton.configuration = config
              addImageButton.backgroundColor = .clear
     
              postImageView.layer.cornerRadius = 0
              postImageView.clipsToBounds = true
              postImageView.contentMode = .scaleAspectFill
     
              removeImageButton.tintColor = .white
              removeImageButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
              removeImageButton.layer.cornerRadius = 14
              removeImageButton.clipsToBounds = true
          }
             
    
    
          // MARK: - Save Draft button
          private func styleSaveDraftButton() {
              saveDraft.setTitleColor(.systemBlue, for: .normal)
              saveDraft.layer.borderWidth = 1.5
              saveDraft.layer.borderColor = UIColor.systemBlue.cgColor
              saveDraft.layer.cornerRadius = 22
          }
    
             func setupTextViewPlaceholder() {
                 placeholderLabel.text = "Description"
                 placeholderLabel.textColor = .secondaryLabel
                 placeholderLabel.font = .systemFont(ofSize: 16)
                 placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                 
                 bodyTextView.addSubview(placeholderLabel)
                 
                 NSLayoutConstraint.activate([
                     placeholderLabel.topAnchor.constraint(equalTo: bodyTextView.topAnchor, constant: 7),
                     placeholderLabel.leadingAnchor.constraint(equalTo: bodyTextView.leadingAnchor, constant: 10),
                     placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: bodyTextView.trailingAnchor, constant: -10)
                 ])
                 
                 bodyTextView.delegate = self  //check this
                 placeholderLabel.isHidden = !bodyTextView.text.isEmpty
             }
             
             
             
             func textViewDidChange(_ textView: UITextView) {
                 placeholderLabel.isHidden = !textView.text.isEmpty
             }
             
             
             
             private func configureForMode() {
                 
                 if mode == .editDraft {
                                           navigationItem.title = "Draft"
                      navigationItem.rightBarButtonItem = nil
                     prefillDraftData()
                 }
             }
             
             private func prefillDraftData() {
                 guard let draft = apiDraft else { return }
                 
                 addTopicTextField.text = draft.tags.joined(separator: ", ")
                 titleTextField.text = draft.title
                 bodyTextView.text = draft.description
                 
                 placeholderLabel.isHidden = !draft.description.isEmpty
                 
                 // Image is optional (important)
                 if let imageUrlStr = draft.imageUrl, let url = URL(string: imageUrlStr) {
                     URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                         guard let data = data, let image = UIImage(data: data) else { return }
                         DispatchQueue.main.async {
                             self?.showDraftImage(image)
                         }
                     }.resume()
                 }
             }
                 func handleSelectedImage(_ image: UIImage) {
                     postImageView.image = image
                     
                     addImageButton.isHidden = true
                     postImageView.isHidden = false
                     removeImageButton.isHidden = false
                     imageContainerHeight.constant = 220
                     
                     imageView.bringSubviewToFront(removeImageButton)
                     
                     UIView.animate(withDuration: 0.25) {
                         self.view.layoutIfNeeded()
                     }
                 }
                 
                 func showDraftImage(_ image: UIImage) {
                     postImageView.image = image
                     
                     addImageButton.isHidden = true
                     postImageView.isHidden = false
                     
                     imageContainerHeight.constant = 220
                 }
                 
                 func removeImage() {
                     postImageView.image = nil
                     
                     postImageView.isHidden = true
                     removeImageButton.isHidden = true
                     addImageButton.isHidden = false
                     
                     imageContainerHeight.constant = 50
                     
                     UIView.animate(withDuration: 0.25) {
                         self.view.layoutIfNeeded()
                     }
                 }
                 
                 func saveImageToDisk(_ image: UIImage) -> String? {
                     guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
                     
                     let fileName = UUID().uuidString + ".jpg"
                     let url = FileManager.default
                         .urls(for: .documentDirectory, in: .userDomainMask)[0]
                         .appendingPathComponent(fileName)
                     
                     do {
                         try data.write(to: url)
                         return url.path
                     } catch {
                         print("Failed to save image:", error)
                         return nil
                     }
                 }
             }
          
          
         extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
          
             func openImagePicker() {
                 let picker = UIImagePickerController()
                 picker.delegate = self
                 picker.sourceType = .photoLibrary
                 present(picker, animated: true)
             }
          
             func imagePickerController(
                 _ picker: UIImagePickerController,
                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
             ) {
                 picker.dismiss(animated: true)
          
                 guard let image = info[.originalImage] as? UIImage else { return }
          
                 handleSelectedImage(image)
             }
         }
