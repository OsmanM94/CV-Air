//
//  CVPreview.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct CVPreview: View {
    @State var cv: CV
    var templateType: CVTemplateType
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch templateType {
                case .original:
                    originalTemplate
                case .modernMinimalist:
                    modernMinimalistTemplate
                case .classicProfessional:
                    classicProfessionalTemplate
                case .compactEfficient:
                    compactEfficientTemplate
                }
            }
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .preferredColorScheme(.dark)
    }
    
    private var originalTemplate: some View {
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
                projectsSection
            }
            
            // Skills
            if !cv.skills.isEmpty {
                skillsSection
            }
        }
        .padding(15)
    }
    
    private var modernMinimalistTemplate: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left Column
            VStack(alignment: .leading, spacing: 20) {
                // Personal Information
                VStack(alignment: .leading, spacing: 5) {
                    Text(cv.personalInfo.name)
                        .font(.system(size: 24, weight: .bold))
                    Text(cv.personalInfo.email)
                        .font(.system(size: 10))
                    Text(cv.personalInfo.phoneNumber)
                        .font(.system(size: 10))
                    Text(cv.personalInfo.address)
                        .font(.system(size: 10))
                }
                
                // Skills
                if !cv.skills.isEmpty {
                    skillsSection
                }
                
                // Education
                if !cv.educationalHistory.isEmpty {
                    historySection(title: "Education", entries: cv.educationalHistory)
                }
            }
            .frame(width: 200)
            
            // Right Column
            VStack(alignment: .leading, spacing: 20) {
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
                    historySection(title: "Experience", entries: cv.professionalHistory)
                }
                
                // Projects
                if !cv.projects.isEmpty {
                    projectsSection
                }
            }
        }
        .padding(15)
    }
    
    private var classicProfessionalTemplate: some View {
        VStack(alignment: .center, spacing: 20) {
            // Personal Information
            VStack(spacing: 5) {
                Text(cv.personalInfo.name)
                    .font(.system(size: 24, weight: .bold))
                Text("\(cv.personalInfo.email) | \(cv.personalInfo.phoneNumber) | \(cv.personalInfo.address)")
                    .font(.system(size: 10))
            }
            
            // Summary
            if !cv.summary.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("SUMMARY")
                        .font(.system(size: 14, weight: .bold))
                    Text(cv.summary)
                        .font(.system(size: 12))
                }
            }
            
            // Professional History
            if !cv.professionalHistory.isEmpty {
                historySection(title: "PROFESSIONAL EXPERIENCE", entries: cv.professionalHistory)
            }
            
            // Educational History
            if !cv.educationalHistory.isEmpty {
                historySection(title: "EDUCATION", entries: cv.educationalHistory)
            }
            
            // Projects
            if !cv.projects.isEmpty {
                projectsSection
            }
            
            // Skills
            if !cv.skills.isEmpty {
                skillsSection
            }
        }
        .padding(15)
    }
    
    private var compactEfficientTemplate: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Personal Information
            HStack {
                VStack(alignment: .leading) {
                    Text(cv.personalInfo.name)
                        .font(.system(size: 18, weight: .bold))
                    Text(cv.personalInfo.email)
                        .font(.system(size: 9))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(cv.personalInfo.phoneNumber)
                        .font(.system(size: 9))
                    Text(cv.personalInfo.address)
                        .font(.system(size: 9))
                }
            }
            
            // Summary
            if !cv.summary.isEmpty {
                Text(cv.summary)
                    .font(.system(size: 10))
            }
            
            // Professional History
            if !cv.professionalHistory.isEmpty {
                historySection(title: "Experience", entries: cv.professionalHistory, compact: true)
            }
            
            // Educational History
            if !cv.educationalHistory.isEmpty {
                historySection(title: "Education", entries: cv.educationalHistory, compact: true)
            }
            
            HStack(alignment: .top, spacing: 10) {
                // Skills
                if !cv.skills.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Skills")
                            .font(.system(size: 12, weight: .bold))
                        Text(cv.skills.joined(separator: " • "))
                            .font(.system(size: 9))
                    }
                }
                
                // Projects
                if !cv.projects.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Projects")
                            .font(.system(size: 12, weight: .bold))
                        ForEach(cv.projects) { project in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.title)
                                    .font(.system(size: 10, weight: .semibold))
                                Text(project.details)
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
    }
    
    private func historySection(title: String, entries: [HistoryEntry], compact: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: compact ? 5 : 10) {
            Text(title)
                .font(.system(size: compact ? 12 : 16, weight: .bold))
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: compact ? 2 : 5) {
                    HStack {
                        Text("\(entry.title), \(entry.subtitle)")
                            .font(.system(size: compact ? 10 : 14, weight: .semibold))
                        Spacer()
                        Text(formatYearRange(start: entry.startYear, end: entry.endYear))
                            .font(.system(size: compact ? 9 : 12))
                    }
                    ForEach(entry.details, id: \.self) { detail in
                        Text("• \(detail)")
                            .font(.system(size: compact ? 9 : 12))
                    }
                }
                .padding(.bottom, compact ? 2 : 5)
            }
        }
    }
    
    private var projectsSection: some View {
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
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Skills")
                .font(.system(size: 16, weight: .bold))
            Text(cv.skills.joined(separator: " • "))
                .font(.system(size: 12))
        }
    }
}
