//
//  MessageView.swift
//  Broche
//
//  Created by Jacob Johnson on 6/10/23.
//

import SwiftUI
import Kingfisher

struct MessageView: View {
    let viewModel: MessageViewModel
    
    var body: some View {
        HStack {
            if viewModel.isFromCurrentUser {
                Spacer()
                Text(viewModel.message.text)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(ChatBubble(isFromCurrentUser: true))
                    .foregroundColor(.white)
                    .padding(.leading, 100)
                    .padding(.trailing)
            } else {
                HStack(alignment: .bottom) {
                    if let user = viewModel.message.user {
                        CircularProfileImageView(user: user, size: .xSmall)
                    }
                    
                    Text(viewModel.message.text)
                        .font(.system(size: 15))
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(ChatBubble(isFromCurrentUser: false))
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}
