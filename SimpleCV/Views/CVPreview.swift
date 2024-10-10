//
//  CVPreview.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct CVPreview: View {
    @State var cv: CV
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Personal Information
                    VStack(alignment: .leading, spacing: 5) {
                        Text(cv.personalInfo.name)
                            .font(.system(size: 24, weight: .bold))
                        Text("\(cv.personalInfo.address) • \(cv.personalInfo.phoneNumber) • \(cv.personalInfo.email)")
                            .font(.system(size: 12))
                        if let website = cv.personalInfo.website, !website.isEmpty {
                            Text("Website: \(website)")
                                .font(.system(size: 12))
                        }
                    }
                    
                    // Summary
                    if !cv.summary.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Summary")
                                .font(.system(size: 16, weight: .bold))
                            Text(cv.summary)
                                .font(.system(size: 12))
                        }
                    }
                    
                    // Professional History
                    if !cv.professionalHistory.isEmpty {
                        historySection(title: "Professional History", entries: cv.professionalHistory)
                    }
                    
                    // Educational History
                    if !cv.educationalHistory.isEmpty {
                        historySection(title: "Educational History", entries: cv.educationalHistory)
                    }
                    
                    // Projects
                    if !cv.projects.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Projects")
                                .font(.system(size: 16, weight: .bold))
                            ForEach(cv.projects) { project in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(project.title)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(project.details)
                                        .font(.system(size: 12))
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                    
                    // Skills
                    if !cv.skills.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Skills")
                                .font(.system(size: 16, weight: .bold))
                            Text(cv.skills.joined(separator: " • "))
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(15)
            }
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .preferredColorScheme(.dark)
    }
    
    private func historySection(title: String, entries: [HistoryEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(entry.title), \(entry.subtitle)")
                        .font(.system(size: 14, weight: .semibold))
                    Text(formatYearRange(start: entry.startYear, end: entry.endYear))
                        .font(.system(size: 12))
                    ForEach(entry.details, id: \.self) { detail in
                        Text("• \(detail)")
                            .font(.system(size: 12))
                    }
                }
                .padding(.bottom, 5)
            }
        }
    }
}
