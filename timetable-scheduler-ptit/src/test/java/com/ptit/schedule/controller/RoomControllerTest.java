package com.ptit.schedule.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ptit.schedule.dto.RoomRequest;
import com.ptit.schedule.dto.RoomResponse;
import com.ptit.schedule.entity.RoomStatus;
import com.ptit.schedule.entity.RoomType;
import com.ptit.schedule.service.RoomService;
import com.ptit.schedule.service.ScheduleService;
import com.ptit.schedule.service.SubjectRoomMappingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.springframework.security.core.userdetails.UserDetailsService;
import com.ptit.schedule.security.JwtTokenProvider;

@WebMvcTest(controllers = RoomController.class, excludeAutoConfiguration = {SecurityAutoConfiguration.class})
@AutoConfigureMockMvc(addFilters = false)
public class RoomControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @MockBean
    private RoomService roomService;

    @MockBean
    private ScheduleService scheduleService;

    @MockBean
    private SubjectRoomMappingService subjectRoomMappingService;

    @Autowired
    private ObjectMapper objectMapper;

    private RoomResponse roomResponse;
    private RoomRequest roomRequest;

    @BeforeEach
    void setUp() {
        roomResponse = RoomResponse.builder()
                .id(1L)
                .name("A2-301")
                .capacity(50)
                .building("A2")
                .type(RoomType.GENERAL)
                .status(RoomStatus.AVAILABLE)
                .build();

        roomRequest = RoomRequest.builder()
                .name("A2-301")
                .capacity(50)
                .building("A2")
                .type(RoomType.GENERAL)
                .build();
    }

    @Test
    void getAllRooms_ShouldReturnRoomList() throws Exception {
        List<RoomResponse> rooms = Arrays.asList(roomResponse);
        when(roomService.getAllRooms()).thenReturn(rooms);

        mockMvc.perform(get("/api/rooms")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].id").value(1L))
                .andExpect(jsonPath("$.data[0].name").value("A2-301"));
    }

    @Test
    void getRoomById_ShouldReturnRoom() throws Exception {
        when(roomService.getRoomById(1L)).thenReturn(roomResponse);

        mockMvc.perform(get("/api/rooms/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(1L))
                .andExpect(jsonPath("$.data.name").value("A2-301"));
    }

    @Test
    void createRoom_ShouldReturnCreatedRoom() throws Exception {
        when(roomService.createRoom(any(RoomRequest.class))).thenReturn(roomResponse);

        mockMvc.perform(post("/api/rooms")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(roomRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(1L))
                .andExpect(jsonPath("$.data.name").value("A2-301"));
    }

    @Test
    void createRoom_WithInvalidData_ShouldReturnBadRequest() throws Exception {
        RoomRequest invalidRequest = RoomRequest.builder()
                .name("") // Invalid blank name
                .capacity(0) // Invalid capacity
                .build();

        mockMvc.perform(post("/api/rooms")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void deleteRoom_ShouldReturnSuccess() throws Exception {
        doNothing().when(roomService).deleteRoom(1L);

        mockMvc.perform(delete("/api/rooms/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
