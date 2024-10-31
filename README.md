# matchAhead
Methods for faster multi-level matching to be submitted to the 2024 ASA Student Paper competition.

## Timeline
* **November 2nd**: Start all simulations
* **November 5th**: Produce a skeleton draft (figures and whatnot may be blank, data may be unfilled) for Ben
* **November 12th**: Produce a first draft, ideally not much needs to be done to edit it at this point.
* **November 15th, 5PM EST**: Submit all materials for computing section
* **November 15th, 11:59PM EST**: Submit all materials for GSS section

## Requirements

### GSS
- **Paper Requirements**
  - **Content**: Research can be ongoing but must include an abstract prospectus describing intended innovations.
  - **Format**:
    - Paper must be **25 pages max** (including all figures, tables, and bibliography).
    - **Double-spaced** throughout, using **12-point font** and at least **1-inch margins** on all sides.

- **Supporting Documents**
  - **Cover Letter**:
    - Include your name, current affiliation, academic status, and contact information (address, phone, and email).
  - **Abstract**:
    - Write an abstract (300 words max) summarizing your research.
  - **Draft Paper**:
    - Format as per the guidelines above.
  - **Advisor Letter**:
    - Have your advisor send a separate letter certifying your student status and describing plans for research completion.

- **Submission Process**
  - **Submission Deadline**: Send your application package (cover letter, abstract, and draft paper) by **11:59 p.m. EST, November 15, 2024**.
  - **Submission Contacts**:
    - Email application materials to all three 2025 section officers:
      - **Xiaojing Wang** (SSS Program Chair-Elect) - [xiaojing.wang@uconn.edu](mailto:xiaojing.wang@uconn.edu)
      - **Kristen Olson** (SRMS Program Chair-Elect) - [kolson5@unl.edu](mailto:kolson5@unl.edu)
      - **Pushpal Mukhopadhyay** (GSS Program Chair-Elect) - [pushpalm@gmail.com](mailto:pushpalm@gmail.com)

### Computing
- **Paper Requirements**
  - **Content**: Include some aspect of Statistical Computing or Graphics:
    - Original methodological research, a novel application, or a software-related project.
  - **Format**:
    - Total length of **6 pages**, including figures, tables, and references (two-column format is allowed).
    - Include a **self-contained** paper (avoid overly compacted font, margins, or line spacing).
    - If necessary, attach supplemental materials (like proofs or additional figures) as an appendix starting on page 7.
  - **Blinded Submission**:
    - Prepare versions of both the abstract and the manuscript with **no identifying author information**.

- **Supporting Documents**
  - **Abstract**: Concise and informative.
  - **CV**: Ensure it’s updated.
  - **Faculty Letter**:
    - Confirm student status for **Fall 2024**.
    - If co-authored, faculty should state your share of the work.

- **Submission Process**
  - **Submission Window**: Opens on **November 1, 2024**.
  - **Deadline**: Ensure all materials are submitted by **5:00 PM EST on Friday, November 15, 2024**.
  - **Where to Submit**: Use the submission form on the competition announcement page.
  - **File Format**: Submit all documents in **PDF** format in English.

## Tasks

### Cake batter
- Create all necessray code for the paper
    - Implement the `group_distances`
        - ~~Implement `make_grouped`~~
        - ~~Implement `model_outcomes`~~
        - Implement `get_se`
        - Implement `calc_caliper`
        - Implement `in_caliper`
        - ~~Implement `get_distances`~~
    - Run simulations
        - Read a bit on how to effectively do a simulation study in this contect
        - Make a `simulations.R` file
            - Experiment with the right parameters for the simulation using simulated data
        - Clone this repo on `cochran` or `peirce` or `evalengin`
        - Set simulations to run
- Calculate Big O for our method as well as the other method
- Decide on which competitions to go for: GSS or Computing (maybe both?)
- Write the damn paper
    - Write introduction
    - Write methodology
    - Write results
    - Write discussion/conclusion
    - Write results
    - Write other sections as necessary
    - Write abstract
- Have others look at it
    - Send skeleton draft to Ben by November 5th
    - Send complete-ish draft to Ben by 
    - Brainstorm others to look at it

### Icing on top
- Export as an R packge
    - Ensure implementation with parallel processing libraries
    - Write test code for all functions
    - Include a vignette explanation

## Links
* [GSS Section Announcement](https://community.amstat.org/governmentstatisticssection/awards/studentpapercompetition)
* [Statistical Computing Section Announcement](https://community.amstat.org/jointscsg-section/awards/student-paper-competition)
