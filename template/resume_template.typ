#let resume-data = json("{{ json_file_path }}")

#show: doc => {
  set text( size: 11pt, fill: black) // A good, professional font
  doc
}

#let old-link = link
#let link(target, body) = {
  old-link(target, text(fill: blue)[#body])
}

// Custom style function for headings
#let section-heading(body) = {
  line(length: 100%, stroke: 1.2pt + rgb("#ccc"))
  heading(level: 2, outlined: false, body)
}

// Custom style function for sub-headings
#let subheading(body) = {
  text(size: 1.1em, weight: "bold", body)
}

#let skills_heading(body) = {
  text(size: 0.9em,baseline: 0.2em, weight: "semibold", body)
}

// Custom style function for dates/company names
#let subtext(body) = {
  h(0.5em)
  text(style: "italic", fill: rgb("#555"), body)
}

// Custom style for skills list
#let tab-list(body) = {
  list(
    body,
    indent: 0pt,
    marker: none,
  )
}

// Custom style for skills list item
#let tab-item(body) = {
  h(0.5em)
  box(
    fill: rgb("#e9e9e9"),
    inset: (x: 8pt, y: 5pt),
    radius: 3pt,
    body,
  )
}

#let format-tabs(tabs-items) = {
  [#tab-list[
      #tabs-items.map(tab => tab-item[#tab]).join()
    ]]
}

// Define colors
#let primary-color = rgb("#007BFF")
#let text-color = rgb("#333")
#let heading-color = rgb("#1a1a1a")

// --- Header Section ---
#align(center)[
  #set text(fill: heading-color)
  #box(
    width: 100%,
    align(center)[
      #set text( size: 24pt, weight: "bold", fill: heading-color)
      #line(length: 100%, stroke: 1.5pt + black)
      #resume-data.basics.name
      #line(length: 100%, stroke: 1.5pt + black)
    ]
  )
  #v(0.5em)
  #set text( size: 11pt, fill: text-color)
  #text(weight: "bold")[#resume-data.basics.label]
  #parbreak()
  #resume-data.basics.location.city , #resume-data.basics.location.region , #resume-data.basics.location.countryCode
  #parbreak()
  #link("mailto:" + resume-data.basics.email)[#resume-data.basics.email] | #resume-data.basics.phone#for profile in resume-data.basics.profiles{  
  " | " + link(profile.url)[#profile.network] 
}
]

// --- Summary Section ---
#section-heading[About]
#par(justify: true)[#resume-data.basics.summary]


// --- Experience Section ---
#section-heading[Experience]
#for work_experience in resume-data.work{
  [#subheading[#work_experience.position]]
  [#subtext[#work_experience.name | #work_experience.startDate - #work_experience.at("endDate",default:"Present")]]
  for value in work_experience.highlights {
    [- #value]
  }

  if work_experience.at("skills",default:()) != (){
    [#skills_heading[Skills]]
    [#format-tabs(work_experience.skills)]
  }
}

// --- Projects Section ---
#section-heading[Projects]
#for project in resume-data.projects{
  link(project.url)[#subheading[#project.name]]
  [#par(justify: true)[#project.description]]
  for value in project.highlights{
    [- #value]
  }
  if project.at("skills",default:()) != (){
    [#skills_heading[Skills]]
    [#format-tabs(project.skills)]
  }
}

// Open Source Contributions
#section-heading[Open Source Contributions]
#for project in resume-data.volunteer{
  link(project.url)[#subheading[#project.organization]]
  [#par(justify: true)[#project.summary]]
  for value in project.highlights{
    [- #value]
  }
  if project.at("skills",default:()) != (){
    [#skills_heading[Skills]]
    [#format-tabs(project.skills)]
  }
  v(1em)
}
// --- Skills Section ---
#section-heading[Skills]
#let unique_list = ()
#for value in resume-data.work.map(elem => elem.at("skills",default:())).flatten(){
  if unique_list.contains(value) == false {
    unique_list.push(value)
  }
}
#for value in resume-data.projects.map(elem => elem.at("skills",default:())).flatten(){
  if unique_list.contains(value) == false {
    unique_list.push(value)
  }
}
#for value in resume-data.volunteer.map(elem => elem.at("skills",default:())).flatten(){
  if unique_list.contains(value) == false {
    unique_list.push(value)
  }
}
#format-tabs(unique_list)

// --- Education Section ---
#section-heading[Education]
#for education in resume-data.education{
  [#subheading[#education.studyType]]
  linebreak()
  [#subtext[#education.institution]]
}

// --- Languages Section ---
#section-heading[Languages]
#let languages_list = resume-data.languages.map(elem => elem.language)

#format-tabs(languages_list)

