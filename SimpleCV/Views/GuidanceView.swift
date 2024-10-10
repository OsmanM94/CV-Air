//
//  GuidanceView.swift
//  SimpleCV
//
//  Created by asia on 09.10.2024.
//

import SwiftUI

struct GuidanceView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color(.systemGray6))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Row(title: "Why Simple CVs Are the Most Effective") {
                            Text("In today's fast-paced digital world, the art of crafting an effective CV has evolved significantly. While it might be tempting to create an elaborate, visually stunning resume, the truth is that simplicity often wins the day.")
                        }
                        
                        Row(title: "The Technological Landscape") {
                            Text("In the past, job applications involved printing resumes on fancy paper and mailing them to potential employers. The process was slow, and recruiters had to manually sift through piles of applications. Today, the landscape has dramatically changed:")
                            
                            BulletList(items: [
                                "Applications are submitted online in minutes.",
                                "Responses can be equally swift.",
                                "Many companies use Applicant Tracking Systems (ATS) to manage the hiring process."
                            ])
                        }
                        
                        Row(title: "Understanding ATS") {
                            Text("An ATS is essentially a sophisticated digital filing cabinet that helps recruiters manage the hiring process and store large volumes of resumes. While these systems are becoming more advanced, they still have limitations in parsing complex document formats.")
                        }
                        
                        Row(title: "The Case for Simplicity") {
                            BulletList(items: [
                                "ATS Compatibility: Simple resumes are more likely to be accurately read and stored by ATS software.",
                                "Readability: When a human reviewer does look at your CV, a clean, straightforward layout makes it easier to quickly scan and assess your qualifications.",
                                "Focus on Content: A simple design puts the spotlight on what really matters - your skills, experiences, and achievements.",
                                "Professionalism: A clean, well-organized CV often appears more professional than an overly designed one.",
                                "Versatility: Simple CVs are more likely to look good across different devices and platforms, including mobile screens."
                            ])
                        }
                        
                        Row(title: "Tips for Effective CV Content") {
                            BulletList(items: [
                                "Be Concise: Keep your writing brief and to the point.",
                                "Use Action Verbs: Start bullet points with strong action words.",
                                "Quantify Achievements: Use numbers and percentages when possible.",
                                "Tailor Your CV: Customize content for each job application.",
                                "Prioritize Relevant Information: Put the most important details first.",
                                "Use Keywords: Include industry-specific terms from the job description.",
                                "Highlight Skills: Emphasize skills that match the job requirements.",
                                "Proofread Carefully: Eliminate all spelling and grammar errors."
                            ])
                        }
                        
                        Row(title: "Common Mistakes to Avoid") {
                            BulletList(items: [
                                "Avoid Lengthy Descriptions: Don't write long paragraphs or sentences.",
                                "Skip Generic Statements: Avoid clichés and vague claims.",
                                "Don't Include Irrelevant Information: Focus on what matters for the job.",
                                "Avoid Personal Details: Exclude age, marital status, or personal photos.",
                                "Don't Use Jargon: Ensure your language is clear and understandable.",
                                "Avoid Unexplained Gaps: Address any significant breaks in your work history.",
                                "Don't Exaggerate: Be honest about your skills and experiences.",
                                "Avoid Outdated Information: Focus on recent and relevant experiences."
                            ])
                        }
                    }
                    .padding()
                    .padding(.top)
                    .navigationTitle("The simpler, the better")
                }
            }
        }
    }
}

fileprivate struct Row<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            content
                .foregroundStyle(.secondary)
        }
    }
}

struct BulletList: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top) {
                    Text("•")
                        .font(.subheadline)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    GuidanceView()
}
