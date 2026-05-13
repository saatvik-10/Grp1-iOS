//
//  MyThreadsProfileHeaderCollectionReusableView.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class MyThreadsProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingCountLabel: UILabel!
   
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
   // @IBOutlet weak var gridTitleLabel: UILabel!
    
    var onFollowersTapped: (() -> Void)?
        var onFollowingTapped: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
     
            let followersTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTap))
            followersCountLabel.isUserInteractionEnabled = true
            followersCountLabel.addGestureRecognizer(followersTap)
     
            let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTap))
            followingCountLabel.isUserInteractionEnabled = true
            followingCountLabel.addGestureRecognizer(followingTap)
        }
     
        @objc private func handleFollowersTap() { onFollowersTapped?() }
        @objc private func handleFollowingTap() { onFollowingTapped?() }
        override func layoutSubviews() {
               super.layoutSubviews()
               // Ensure circular image AFTER Auto Layout
               profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
           }
        
        private func setupUI() {
            backgroundColor = .clear
            profileImageView.clipsToBounds = true
            
            // 1. Remove labels from superview to break the broken hardcoded XIB constraints
            userNameLabel.removeFromSuperview()
            postsCountLabel.removeFromSuperview()
            followersCountLabel.removeFromSuperview()
            followingCountLabel.removeFromSuperview()
            
            // 2. Configure text styling
            userNameLabel.textColor = .black
            userNameLabel.font = .systemFont(ofSize: 18, weight: .bold)
            
            [postsCountLabel, followersCountLabel, followingCountLabel].forEach {
                $0?.textColor = .black
                $0?.font = .systemFont(ofSize: 14, weight: .medium)
                $0?.numberOfLines = 0
                $0?.textAlignment = .center
            }
            
            // 3. Create a dynamic, auto-resizing StackView for the stats
            let statsStack = UIStackView(arrangedSubviews: [postsCountLabel, followersCountLabel, followingCountLabel])
            statsStack.axis = .horizontal
            statsStack.distribution = .fillEqually
            statsStack.alignment = .center
            statsStack.spacing = 8
            
            // 4. Add them back to the view
            addSubview(userNameLabel)
            addSubview(statsStack)
            
            userNameLabel.translatesAutoresizingMaskIntoConstraints = false
            statsStack.translatesAutoresizingMaskIntoConstraints = false
            
            // 5. Apply perfectly responsive programmatic constraints
            NSLayoutConstraint.activate([
                // Username label pinned to the right of the profile image
                userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
                userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 12),
                
                // Stats stack pinned right below the username
                statsStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
                statsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                statsStack.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 12)
            ])
         }
            
            func configure(
                userName: String,
                profileImage: String?,
                posts: Int,
                followers: Int,
                following: Int
            ) {
                userNameLabel.text = userName
                if let profileImage = profileImage, !profileImage.isEmpty {
                    profileImageView.setSmartImage(from: profileImage)
                } else {
                    profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
                
                postsCountLabel.text = "\(posts)\nposts"
                followersCountLabel.text = "\(followers)\nfollowers"
                followingCountLabel.text = "\(following)\nfollowing"
            }
        
        
    }  
