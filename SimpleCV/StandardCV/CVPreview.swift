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
    var fontSize: CVFontSize
    var spacing: CVSpacing
    
    var body: some View {
        ScrollView {
            Text("Tip: For accurate preview use Export PDF")
                .font(.system(size: 10 * fontSize.scaleFactor))
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            
            VStack(alignment: .leading, spacing: 20 * spacing.scaleFactor) {
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
        VStack(alignment: .leading, spacing: 20 * spacing.scaleFactor) {
            // Personal Information
            VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                Text(cv.personalInfo.name)
                    .font(.system(size: 24 * fontSize.scaleFactor, weight: .bold))
                Text("\(cv.personalInfo.address) • \(cv.personalInfo.phoneNumber) • \(cv.personalInfo.email)")
                    .font(.system(size: 12 * fontSize.scaleFactor))
                if let website = cv.personalInfo.website, !website.isEmpty {
                    Text("Website: \(website)")
                        .font(.system(size: 12 * fontSize.scaleFactor))
                }
            }
            
            // Summary
            if !cv.summary.isEmpty {
                VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                    Text("Summary")
                        .font(.system(size: 16 * fontSize.scaleFactor, weight: .bold))
                    Text(cv.summary)
                        .font(.system(size: 12 * fontSize.scaleFactor))
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
        .padding(15 * spacing.scaleFactor)
    }
    
    private var modernMinimalistTemplate: some View {
        HStack(alignment: .top, spacing: 20 * spacing.scaleFactor) {
            // Left Column
            VStack(alignment: .leading, spacing: 20 * spacing.scaleFactor) {
                // Personal Information
                VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                    Text(cv.personalInfo.name)
                        .font(.system(size: 24 * fontSize.scaleFactor, weight: .bold))
                    Text(cv.personalInfo.email)
                        .font(.system(size: 10 * fontSize.scaleFactor))
                    Text(cv.personalInfo.phoneNumber)
                        .font(.system(size: 10 * fontSize.scaleFactor))
                    Text(cv.personalInfo.address)
                        .font(.system(size: 10 * fontSize.scaleFactor))
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
            .frame(width: 200 * fontSize.scaleFactor)
            
            // Right Column
            VStack(alignment: .leading, spacing: 20 * spacing.scaleFactor) {
                // Summary
                if !cv.summary.isEmpty {
                    VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                        Text("Summary")
                            .font(.system(size: 16 * fontSize.scaleFactor, weight: .bold))
                        Text(cv.summary)
                            .font(.system(size: 12 * fontSize.scaleFactor))
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
        .padding(15 * spacing.scaleFactor)
    }
    
    private var classicProfessionalTemplate: some View {
        VStack(alignment: .leading, spacing: 20 * spacing.scaleFactor) {
            // Personal Information
            VStack(spacing: 5 * spacing.scaleFactor) {
                Text(cv.personalInfo.name)
                    .font(.system(size: 24 * fontSize.scaleFactor, weight: .bold))
                Text("\(cv.personalInfo.email) | \(cv.personalInfo.phoneNumber) | \(cv.personalInfo.address)")
                    .font(.system(size: 10 * fontSize.scaleFactor))
            }
            
            // Summary
            if !cv.summary.isEmpty {
                VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                    Text("SUMMARY")
                        .font(.system(size: 14 * fontSize.scaleFactor, weight: .bold))
                    Text(cv.summary)
                        .font(.system(size: 12 * fontSize.scaleFactor))
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
        .padding(15 * spacing.scaleFactor)
    }
    
    private var compactEfficientTemplate: some View {
        VStack(alignment: .leading, spacing: 10 * spacing.scaleFactor) {
            // Personal Information
            HStack {
                VStack(alignment: .leading) {
                    Text(cv.personalInfo.name)
                        .font(.system(size: 18 * fontSize.scaleFactor, weight: .bold))
                    Text(cv.personalInfo.email)
                        .font(.system(size: 9 * fontSize.scaleFactor))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(cv.personalInfo.phoneNumber)
                        .font(.system(size: 9 * fontSize.scaleFactor))
                    Text(cv.personalInfo.address)
                        .font(.system(size: 9 * fontSize.scaleFactor))
                }
            }
            
            // Summary
            if !cv.summary.isEmpty {
                Text(cv.summary)
                    .font(.system(size: 10 * fontSize.scaleFactor))
            }
            
            // Professional History
            if !cv.professionalHistory.isEmpty {
                historySection(title: "Experience", entries: cv.professionalHistory, compact: true)
            }
            
            // Educational History
            if !cv.educationalHistory.isEmpty {
                historySection(title: "Education", entries: cv.educationalHistory, compact: true)
            }
            
            HStack(alignment: .top, spacing: 10 * spacing.scaleFactor) {
                // Skills
                if !cv.skills.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Skills")
                            .font(.system(size: 12 * fontSize.scaleFactor, weight: .bold))
                        Text(cv.skills.joined(separator: " • "))
                            .font(.system(size: 9 * fontSize.scaleFactor))
                    }
                }
                
                // Projects
                if !cv.projects.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Projects")
                            .font(.system(size: 12 * fontSize.scaleFactor, weight: .bold))
                        ForEach(cv.projects) { project in
                            VStack(alignment: .leading, spacing: 2 * spacing.scaleFactor) {
                                Text(project.title)
                                    .font(.system(size: 10 * fontSize.scaleFactor, weight: .semibold))
                                Text(project.details)
                                    .font(.system(size: 9 * fontSize.scaleFactor))
                            }
                        }
                    }
                }
            }
        }
        .padding(10 * spacing.scaleFactor)
    }
    
    private func historySection(title: String, entries: [HistoryEntry], compact: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: compact ? 5 * spacing.scaleFactor : 10 * spacing.scaleFactor) {
            Text(title)
                .font(.system(size: (compact ? 12 : 16) * fontSize.scaleFactor, weight: .bold))
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: compact ? 2 * spacing.scaleFactor : 5 * spacing.scaleFactor) {
                    HStack {
                        Text("\(entry.title), \(entry.subtitle)")
                            .font(.system(size: (compact ? 10 : 14) * fontSize.scaleFactor, weight: .semibold))
                        Spacer()
                        Text(formatYearRange(start: entry.startYear, end: entry.endYear))
                            .font(.system(size: (compact ? 9 : 12) * fontSize.scaleFactor))
                    }
                    ForEach(entry.details, id: \.self) { detail in
                        Text("• \(detail)")
                            .font(.system(size: (compact ? 9 : 12) * fontSize.scaleFactor))
                    }
                }
                .padding(.bottom, (compact ? 2 : 5) * spacing.scaleFactor)
            }
        }
    }
    
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 10 * spacing.scaleFactor) {
            Text("Projects")
                .font(.system(size: 16 * fontSize.scaleFactor, weight: .bold))
            ForEach(cv.projects) { project in
                VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
                    Text(project.title)
                        .font(.system(size: 14 * fontSize.scaleFactor, weight: .semibold))
                    Text(project.details)
                        .font(.system(size: 12 * fontSize.scaleFactor))
                }
                .padding(.bottom, 5 * spacing.scaleFactor)
            }
        }
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 5 * spacing.scaleFactor) {
            Text("Skills")
                .font(.system(size: 16 * fontSize.scaleFactor, weight: .bold))
            ForEach(cv.skills, id: \.self) { skill in
                VStack(alignment: .leading) {
                    Text("• \(skill)")
                        .font(.system(size: 12 * fontSize.scaleFactor))
                }
            }
        }
    }
}
