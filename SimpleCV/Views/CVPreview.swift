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
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Professional History")
                                .font(.system(size: 16, weight: .bold))
                            ForEach(cv.professionalHistory) { experience in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(experience.company), \(experience.position)")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(formatYearRange(start: experience.startYear, end: experience.endYear))
                                        .font(.system(size: 12))
                                    ForEach(experience.responsibilities, id: \.self) { responsibility in
                                        Text("• \(responsibility)")
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                    
                    // Educational History
                    if !cv.educationalHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Educational History")
                                .font(.system(size: 16, weight: .bold))
                            ForEach(cv.educationalHistory) { education in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(education.institution)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("\(education.degree), \(formatYearRange(start: education.startYear, end: education.endYear))")
                                        .font(.system(size: 12))
                                    Text(education.details)
                                        .font(.system(size: 12))
                                }
                                .padding(.bottom, 5)
                            }
                        }
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
}

