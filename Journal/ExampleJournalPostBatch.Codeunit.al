codeunit 50018 "Ex. Jnl.-Post Batch"
{
    TableNo = "Ex. Journal Line";

    trigger OnRun();
    begin
        ExJnlLine.COPY(Rec);
        Code4;
        Rec := ExJnlLine;
    end;

    var
        ExJnlTemplate: Record "Ex. Journal Template";
        ExJnlBatch: Record "Ex. Journal Batch";
        ExJnlLine: Record "Ex. Journal Line";
        ExJnlLine2: Record "Ex. Journal Line";
        ExJnlLine3: Record "Ex. Journal Line";
        ExReg: Record 50015;
        NoSeries: Record 308 temporary;
        AccountingPeriod: Record 50;
        ExJnlCheckLine: Codeunit "Ex. Jnl.-Check Line";
        ExJnlPostLine: Codeunit "Ex. Jnl.-Post Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit 396;
        "0DF": DateFormula;
        Window: Dialog;
        ExRegNo: Integer;
        StartLineNo: Integer;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        LineCount: Integer;
        NoOfRecords: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        ToManyCharErr: Label 'cannot exceed %1 characters';
        JnlBatchNameTxt: Label 'Journal Batch Name    #1##########\\';
        CheckingLinesTxt: Label 'Checking lines        #2######\';
        PostingLinesTxt: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        UpdatingLinesTxt: Label 'Updating lines        #5###### @6@@@@@@@@@@@@@';
        PostingLinesProgressTxt: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
        MaxPostingSeriesErr: Label 'A maximum of %1 posting number series can be used in each journal.';
        MonthTextTxt: Label '<Month Text>';


    local procedure Code4();
    var
        UpdateAnalysisView: Codeunit 410;
    begin
        WITH ExJnlLine DO begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            LOCKTABLE;

            ExJnlTemplate.Get("Journal Template Name");
            ExJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if STRLEN(INCSTR(ExJnlBatch.Name)) > MAXSTRLEN(ExJnlBatch.Name) then
                ExJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    ToManyCharErr,
                    MAXSTRLEN(ExJnlBatch.Name)));

            if ExJnlTemplate.Recurring then begin
                SetRange("Posting Date", 0D, WORKDATE);
                SETFILTER("Expiration Date", '%1 | %2..', 0D, WORKDATE);
            end;

            if NOT FIND('=><') then begin
                "Line No." := 0;
                COMMIT;
                exit;
            end;

            if ExJnlTemplate.Recurring then
                Window.OPEN(
                  JnlBatchNameTxt +
                  CheckingLinesTxt +
                  PostingLinesTxt +
                  UpdatingLinesTxt)
            else
                Window.OPEN(
                  JnlBatchNameTxt +
                  CheckingLinesTxt +
                  PostingLinesProgressTxt);
            Window.UPDATE(1, "Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := "Line No.";
            REPEAT
                LineCount := LineCount + 1;
                Window.UPDATE(2, LineCount);
                CheckRecurringLine(ExJnlLine);
                ExJnlCheckLine.RunCheck(ExJnlLine);
                if NEXT = 0 then
                    FIND('-');
            UNTIL "Line No." = StartLineNo;
            NoOfRecords := LineCount;

            // Find next register no.
            ExReg.LOCKTABLE;
            if ExReg.FIND('+') AND (ExReg."To Entry No." = 0) then
                ExRegNo := ExReg."No."
            else
                ExRegNo := ExReg."No." + 1;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastDocNo2 := '';
            LastPostedDocNo := '';
            FIND('-');
            REPEAT
                LineCount := LineCount + 1;
                Window.UPDATE(3, LineCount);
                Window.UPDATE(4, ROUND(LineCount / NoOfRecords * 10000, 1));
                if NOT EmptyLine AND
                   (ExJnlBatch."No. Series" <> '') AND
                   ("Document No." <> LastDocNo2)
                then
                    TestField("Document No.", NoSeriesMgt.GetNextNo(ExJnlBatch."No. Series", "Posting Date", FALSE));
                if NOT EmptyLine then
                    LastDocNo2 := "Document No.";
                MakeRecurringTexts(ExJnlLine);
                if "Posting No. Series" = '' then
                    "Posting No. Series" := ExJnlBatch."No. Series"
                else
                    if NOT EmptyLine then
                        if "Document No." = LastDocNo then
                            "Document No." := LastPostedDocNo
                        else begin
                            if NOT NoSeries.Get("Posting No. Series") then begin
                                NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                                if NoOfPostingNoSeries > arrayLEN(NoSeriesMgt2) then
                                    Error(
                                      MaxPostingSeriesErr,
                                      arrayLEN(NoSeriesMgt2));
                                NoSeries.Code := "Posting No. Series";
                                NoSeries.Description := FORMAT(NoOfPostingNoSeries);
                                NoSeries.INSERT;
                            end;
                            LastDocNo := "Document No.";
                            EVALUATE(PostingNoSeriesNo, NoSeries.Description);
                            "Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo("Posting No. Series", "Posting Date", FALSE);
                            LastPostedDocNo := "Document No.";
                        end;
                ExJnlPostLine.RunWithCheck(ExJnlLine);
            UNTIL NEXT = 0;

            // Copy register no. and current journal batch name to the res. journal
            if NOT ExReg.FIND('+') OR (ExReg."No." <> ExRegNo) then
                ExRegNo := 0;

            INIT;
            "Line No." := ExRegNo;

            // Update/delete lines
            if ExRegNo <> 0 then
                if ExJnlTemplate.Recurring then begin
                    // Recurring journal
                    LineCount := 0;
                    ExJnlLine2.COPYFILTERS(ExJnlLine);
                    ExJnlLine2.FIND('-');
                    REPEAT
                        LineCount := LineCount + 1;
                        Window.UPDATE(5, LineCount);
                        Window.UPDATE(6, ROUND(LineCount / NoOfRecords * 10000, 1));
                        if ExJnlLine2."Posting Date" <> 0D then
                            ExJnlLine2.Validate("Posting Date", CALCDATE(ExJnlLine2."Recurring Frequency", ExJnlLine2."Posting Date"));
                        if (ExJnlLine2."Recurring Method" = ExJnlLine2."Recurring Method"::Variable) then
                            ExJnlLine2.Quantity := 0;
                        ExJnlLine2.Modify;
                    UNTIL ExJnlLine2.NEXT = 0;
                end else begin
                    // Not a recurring journal
                    ExJnlLine2.COPYFILTERS(ExJnlLine);
                    if ExJnlLine2.FIND('+') then; // Remember the last line
                    ExJnlLine3.COPY(ExJnlLine);
                    ExJnlLine3.DeleteAll;
                    ExJnlLine3.RESET;
                    ExJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
                    ExJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                    if NOT ExJnlLine3.FINDLAST then
                        if INCSTR("Journal Batch Name") <> '' then begin
                            ExJnlBatch.DELETE;
                            ExJnlBatch.Name := INCSTR("Journal Batch Name");
                            if ExJnlBatch.INSERT then;
                            "Journal Batch Name" := ExJnlBatch.Name;
                        end;

                    ExJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                    if (ExJnlBatch."No. Series" = '') AND NOT ExJnlLine3.FINDLAST then begin
                        ExJnlLine3.INIT;
                        ExJnlLine3."Journal Template Name" := "Journal Template Name";
                        ExJnlLine3."Journal Batch Name" := "Journal Batch Name";
                        ExJnlLine3."Line No." := 10000;
                        ExJnlLine3.INSERT;
                        ExJnlLine3.SetUpNewLine(ExJnlLine2);
                        ExJnlLine3.MODifY;
                    end;
                end;
        end;
        if ExJnlBatch."No. Series" <> '' then
            NoSeriesMgt.SaveNoSeries;
        if NoSeries.FIND('-') then
            REPEAT
                EVALUATE(PostingNoSeriesNo, NoSeries.Description);
                NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
            UNTIL NoSeries.NEXT = 0;

        COMMIT;

        UpdateAnalysisView.UpdateAll(0, true);
        COMMIT;
    end;

    local procedure CheckRecurringLine(var ExJnlLine2: Record 50013);
    begin
        with ExJnlLine2 do
            if ExJnlTemplate.Recurring then begin
                TestField("Recurring Method");
                TestField("Recurring Frequency");
                if "Recurring Method" = "Recurring Method"::Variable then
                    TestField(Quantity);
            end else begin
                TestField("Recurring Method", 0);
                TestField("Recurring Frequency", "0DF");
            end;

    end;

    local procedure MakeRecurringTexts(var ExJnlLine2: Record 50013);
    begin
        WITH ExJnlLine2 DO
            if "Recurring Method" <> 0 then begin // Not recurring
                Day := DATE2DMY("Posting Date", 1);
                Week := DATE2DWY("Posting Date", 2);
                Month := DATE2DMY("Posting Date", 2);
                MonthText := FORMAT("Posting Date", 0, MonthTextTxt);
                AccountingPeriod.SetRange("Starting Date", 0D, "Posting Date");
                if NOT AccountingPeriod.FIND('+') then
                    AccountingPeriod.Name := '';
                "Document No." :=
                  DelChr(
                    PadStr(
                      StrSubstNo("Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MAXSTRLEN("Document No.")),
                    '>').Substring(1, MaxStrLen("Document No."));
                Description :=
                  DelChr(
                    PadStr(
                      StrSubstNo(Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MAXSTRLEN(Description)),
                    '>').Substring(1, MaxStrLen("Document No."));
            end;

    end;
}

