codeunit 50012 "Ex. Jnl.-Check Line"
{
    TableNo = "Ex. Journal Line";

    trigger OnRun();
    begin
        GLSetup.Get;
        RunCheck(Rec);
    end;

    var

        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        DimMgt: Codeunit DimensionManagement;
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        CannotBeClosingDateErr: Label 'cannot be a closing date';
        NotInRangeErr: Label 'is not within your range of allowed posting dates';
        DimensionBlockedErr: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';

    procedure RunCheck(var ExJnlLine: Record "Ex. Journal Line");
    begin
        WITH ExJnlLine DO begin
            if EmptyLine then
                exit;

            OnTestNearRunCheck(ExJnlLine);

            TestField("Posting Date");
            TestField("Gen. Prod. Posting Group");

            if "Posting Date" <> NORMALDATE("Posting Date") then
                FieldError("Posting Date", CannotBeClosingDateErr);

            if (AllowPostingFrom = 0D) AND (AllowPostingTo = 0D) then begin
                if UserId <> '' then
                    if UserSetup.Get(UserId) then begin
                        AllowPostingFrom := UserSetup."Allow Posting From";
                        AllowPostingTo := UserSetup."Allow Posting To";
                    end;
                if (AllowPostingFrom = 0D) AND (AllowPostingTo = 0D) then begin
                    GLSetup.Get;
                    AllowPostingFrom := GLSetup."Allow Posting From";
                    AllowPostingTo := GLSetup."Allow Posting To";
                end;
                if AllowPostingTo = 0D then
                    AllowPostingTo := DMY2Date(31, 12, 9999);
            end;
            if ("Posting Date" < AllowPostingFrom) OR ("Posting Date" > AllowPostingTo) then
                FieldError("Posting Date", NotInRangeErr);

            if "Document Date" <> 0D then
                if "Document Date" <> NORMALDATE("Document Date") then
                    FieldError("Document Date", CannotBeClosingDateErr);

            if NOT DimMgt.CheckDimIDComb("Dimension Set ID") then
                Error(
                  DimensionBlockedErr,
                  TABLECAPTION, "Journal Template Name", "Journal Batch Name", "Line No.",
                  DimMgt.GetDimCombErr);

            OnTestFarRunCheck(ExJnlLine);


        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestNearRunCheck(var ExJnlLine: Record "Ex. Journal Line")
    begin
        // To Do Implement Implementation
        //TestField("Example Person No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestFarRunCheck(var ExJnlLine: Record "Ex. Journal Line")
    begin
        //      DimensionCausedErrorErr: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        // To Do - Implementation Pattern

        // TableID[1] := DATABASE::"Example Person";
        // No[1] := "Example Person No.";
        // if NOT DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
        //     if "Line No." <> 0 then
        //         Error(
        //           DimensionCausedErrorErr,
        //           TABLECAPTION, "Journal Template Name", "Journal Batch Name", "Line No.",
        //           DimMgt.GetDimValuePostingErr)
        //     else
        //         Error(DimMgt.GetDimValuePostingErr);
    end;
}

