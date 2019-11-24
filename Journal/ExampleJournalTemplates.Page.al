page 50012 "Example Journal Templates"
{
    // version Exercise 3

    Caption = 'Example Journal Templates';
    PageType = List;
    SourceTable = "Ex. Journal Template";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Recurring; Recurring)
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Posting No. Series"; "Posting No. Series")
                {
                    ApplicationArea = All;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Page Caption"; "Page Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Visible = false;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = All;

                    Visible = false;
                }
                field("Test Report Caption"; "Test Report Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Visible = false;
                }
                field("Posting Report ID"; "Posting Report ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Report Caption"; "Posting Report Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Visible = false;
                }
                field("Force Posting Report"; "Force Posting Report")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                Image = Template;
                action(Batches)
                {
                    ApplicationArea = All;
                    Caption = 'Batches';
                    Image = Description;
                    RunObject = Page "Example Jnl. Batches";
                    RunPageLink = "Journal Template Name" = FIELD(Name);
                }
            }
        }
    }
}

