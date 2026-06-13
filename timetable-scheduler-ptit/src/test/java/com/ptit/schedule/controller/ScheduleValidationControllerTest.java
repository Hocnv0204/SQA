package com.ptit.schedule.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ptit.schedule.dto.ConflictResult;
import com.ptit.schedule.dto.ScheduleEntry;
import com.ptit.schedule.service.ScheduleConflictDetectionService;
import com.ptit.schedule.service.ScheduleExcelReaderService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

import org.springframework.security.core.userdetails.UserDetailsService;
import com.ptit.schedule.security.JwtTokenProvider;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = ScheduleValidationController.class, excludeAutoConfiguration = {SecurityAutoConfiguration.class})
@AutoConfigureMockMvc(addFilters = false)
public class ScheduleValidationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @MockBean
    private ScheduleExcelReaderService excelReaderService;

    @MockBean
    private ScheduleConflictDetectionService conflictDetectionService;

    @Autowired
    private ObjectMapper objectMapper;

    private MockMultipartFile validFile;
    private MockMultipartFile emptyFile;

    @BeforeEach
    void setUp() {
        validFile = new MockMultipartFile(
                "file",
                "schedule.xlsx",
                MediaType.MULTIPART_FORM_DATA_VALUE,
                "dummy excel content".getBytes()
        );

        emptyFile = new MockMultipartFile(
                "file",
                "empty.xlsx",
                MediaType.MULTIPART_FORM_DATA_VALUE,
                new byte[0]
        );
    }

    @Test
    void validateExcelFormat_WithValidFile_ShouldReturnSuccess() throws Exception {
        when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);

        mockMvc.perform(multipart("/api/schedule-validation/validate-format")
                        .file(validFile))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void validateExcelFormat_WithEmptyFile_ShouldReturnBadRequest() throws Exception {
        mockMvc.perform(multipart("/api/schedule-validation/validate-format")
                        .file(emptyFile))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void validateExcelFormat_WithInvalidFormat_ShouldReturnBadRequest() throws Exception {
        when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(false);

        mockMvc.perform(multipart("/api/schedule-validation/validate-format")
                        .file(validFile))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void analyzeSchedule_WithValidFile_ShouldReturnResult() throws Exception {
        when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);

        List<ScheduleEntry> entries = new ArrayList<>();
        entries.add(new ScheduleEntry()); // Add dummy entry
        when(excelReaderService.readScheduleFromExcel(any())).thenReturn(entries);

        ConflictResult conflictResult = new ConflictResult(); // Dummy conflict result
        when(conflictDetectionService.detectConflicts(any())).thenReturn(conflictResult);

        mockMvc.perform(multipart("/api/schedule-validation/analyze")
                        .file(validFile))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.fileName").value("schedule.xlsx"));
    }

    @Test
    void analyzeSchedule_WithEmptyData_ShouldReturnBadRequest() throws Exception {
        when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);
        when(excelReaderService.readScheduleFromExcel(any())).thenReturn(new ArrayList<>());

        mockMvc.perform(multipart("/api/schedule-validation/analyze")
                        .file(validFile))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Không tìm thấy dữ liệu thời khóa biểu trong file. Vui lòng kiểm tra lại."));
    }

    @Test
    void getConflictDetails_ShouldReturnSuccess() throws Exception {
        mockMvc.perform(get("/api/schedule-validation/conflicts/room")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
