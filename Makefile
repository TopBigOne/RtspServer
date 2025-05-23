V4L2_SUPPORT=n
ALSA_SUPPORT=n

CROSS_COMPILE	=
CXX   			= $(CROSS_COMPILE)g++

TOR_DIR 	= $(shell pwd)
SRC_DIR 	= $(TOR_DIR)/src
OBJS_PATH 	= $(TOR_DIR)/objs

CXX_FLAGS 	= -O0 -g -I$(TOR_DIR)/src

LD_FLAGS 	= -lpthread -lrt

ifeq ($(V4L2_SUPPORT),y)
LD_FLAGS	+= -lx264
endif

ifeq ($(ALSA_SUPPORT),y)
LD_FLAGS 	+= -lasound -lfaac
endif



SRC_BASE		= $(shell find $(SRC_DIR)/base -name *.cpp)
SRC_NET			= $(shell find $(SRC_DIR)/net -name *.cpp)
SRC_EXTEND_V4L2	= $(shell find $(SRC_DIR)/extend/v4l2 -name *.cpp)
SRC_EXTEND_ALSA	= $(shell find $(SRC_DIR)/extend/alsa -name *.cpp)

SRC_BASE_NODIR			= $(notdir $(wildcard $(SRC_BASE)))
SRC_NET_NODIR			= $(notdir $(wildcard $(SRC_NET)))
SRC_EXTEND_V4L2_NODIR	= $(notdir $(wildcard $(SRC_EXTEND_V4L2)))
SRC_EXTEND_ALSA_NODIR	= $(notdir $(wildcard $(SRC_EXTEND_ALSA)))

OBJS_BASE			= $(patsubst %.cpp,$(OBJS_PATH)/%.o,$(SRC_BASE_NODIR))
OBJS_NET			= $(patsubst %.cpp,$(OBJS_PATH)/%.o,$(SRC_NET_NODIR))
OBJS_EXTEND_V4L2	= $(patsubst %.cpp,$(OBJS_PATH)/%.o,$(SRC_EXTEND_V4L2_NODIR))
OBJS_EXTEND_ALSA	= $(patsubst %.cpp,$(OBJS_PATH)/%.o,$(SRC_EXTEND_ALSA_NODIR))



OBJ_TEST_LOG			= $(OBJS_PATH)/01_test_log.o
OBJ_TEST_ADD_EVENT		= $(OBJS_PATH)/02_test_add_event.o
OBJ_TEST_THREAD_POOL	= $(OBJS_PATH)/03_test_thread_pool.o
OBJ_TEST_ACCEPTOR		= $(OBJS_PATH)/04_test_acceptor.o

TARGET_TEST_LOG 		= $(TOR_DIR)/test/test_log
TARGET_TEST_ADD_EVENT 	= $(TOR_DIR)/test/test_add_event
TARGET_TEST_THREAD_POOL = $(TOR_DIR)/test/test_thread_pool
TARGET_TEST_ACCEPTOR 	= $(TOR_DIR)/test/test_acceptor

c				= $(OBJS_PATH)/01_h264_rtsp_server.o
OBJ_EXAMPLE_AAC_RTSP_SERVER					= $(OBJS_PATH)/02_aac_rtsp_server.o
OBJ_EXAMPLE_H264_AAC_RTSP_SERVER			= $(OBJS_PATH)/03_h264_aac_rtsp_server.o
OBJ_EXAMPLE_V4L2_RTSP_SERVER				= $(OBJS_PATH)/04_v4l2_rtsp_server.o
OBJ_EXAMPLE_ALSA_RTSP_SERVER				= $(OBJS_PATH)/05_alsa_rtsp_server.o

TARGET_TEST_EXAMPLE_H264_RTSP_SERVER		= $(TOR_DIR)/example/h264_rtsp_server
TARGET_TEST_EXAMPLE_AAC_RTSP_SERVER			= $(TOR_DIR)/example/aac_rtsp_server
TARGET_TEST_EXAMPLE_H264_AAC_RTSP_SERVER	= $(TOR_DIR)/example/h264_aac_rtsp_server
TARGET_TEST_EXAMPLE_V4L2_RTSP_SERVER		= $(TOR_DIR)/example/v4l2_rtsp_server
TARGET_TEST_EXAMPLE_ALSA_RTSP_SERVER		= $(TOR_DIR)/example/alsa_rtsp_server



all: MKAE_DIR TARGET_TEST TARGET_EXAMPLE

MKAE_DIR:
	@-mkdir -p $(OBJS_PATH)



TARGET_TEST : $(TARGET_TEST_LOG) $(TARGET_TEST_ADD_EVENT) $(TARGET_TEST_THREAD_POOL)\
			$(TARGET_TEST_ACCEPTOR)

$(TARGET_TEST_LOG) : $(OBJ_TEST_LOG) $(OBJS_BASE)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_ADD_EVENT) : $(OBJ_TEST_ADD_EVENT) $(OBJS_BASE) $(OBJS_NET)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_THREAD_POOL) : $(OBJ_TEST_THREAD_POOL) $(OBJS_BASE)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_ACCEPTOR) : $(OBJ_TEST_ACCEPTOR) $(OBJS_BASE) $(OBJS_NET)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)



TARGET_EXAMPLE : $(TARGET_TEST_EXAMPLE_H264_RTSP_SERVER) $(TARGET_TEST_EXAMPLE_AAC_RTSP_SERVER)\
				$(TARGET_TEST_EXAMPLE_H264_AAC_RTSP_SERVER)

ifeq ($(V4L2_SUPPORT),y)
TARGET_EXAMPLE : $(TARGET_TEST_EXAMPLE_V4L2_RTSP_SERVER)
endif

ifeq ($(ALSA_SUPPORT),y)
TARGET_EXAMPLE : $(TARGET_TEST_EXAMPLE_ALSA_RTSP_SERVER)
endif



$(TARGET_TEST_EXAMPLE_H264_RTSP_SERVER) : $(OBJ_EXAMPLE_H264_RTSP_SERVER) $(OBJS_BASE) $(OBJS_NET)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_EXAMPLE_AAC_RTSP_SERVER) : $(OBJ_EXAMPLE_AAC_RTSP_SERVER) $(OBJS_BASE) $(OBJS_NET)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_EXAMPLE_H264_AAC_RTSP_SERVER) : $(OBJ_EXAMPLE_H264_AAC_RTSP_SERVER) $(OBJS_BASE) $(OBJS_NET)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_EXAMPLE_V4L2_RTSP_SERVER) : $(OBJ_EXAMPLE_V4L2_RTSP_SERVER) $(OBJS_BASE) $(OBJS_NET) $(OBJS_EXTEND_V4L2)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)

$(TARGET_TEST_EXAMPLE_ALSA_RTSP_SERVER) : $(OBJ_EXAMPLE_ALSA_RTSP_SERVER) $(OBJS_BASE) $(OBJS_NET) $(OBJS_EXTEND_ALSA)
	$(CXX) $^ -o $@ $(LD_FLAGS) $(CXX_FLAGS)



$(OBJS_PATH)/%.o : $(TOR_DIR)/example/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(TOR_DIR)/test/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(SRC_DIR)/base/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(SRC_DIR)/net/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(SRC_DIR)/net/poller/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(SRC_DIR)/extend/alsa/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(OBJS_PATH)/%.o : $(SRC_DIR)/extend/v4l2/%.cpp
	$(CXX) -c -o $@ $< $(CXX_FLAGS)



# /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

.PHONY : clean
clean:
	rm -rf $(OBJS_PATH)
	rm -rf $(TARGET_TEST_LOG)
	rm -rf $(TARGET_TEST_ADD_EVENT)
	rm -rf $(TARGET_TEST_THREAD_POOL)
	rm -rf $(TARGET_TEST_ACCEPTOR)
	rm -rf $(TARGET_TEST_EXAMPLE_H264_RTSP_SERVER)
	rm -rf $(TARGET_TEST_EXAMPLE_AAC_RTSP_SERVER)
	rm -rf $(TARGET_TEST_EXAMPLE_H264_AAC_RTSP_SERVER)
	rm -rf $(TARGET_TEST_EXAMPLE_V4L2_RTSP_SERVER)
	rm -rf $(TARGET_TEST_EXAMPLE_ALSA_RTSP_SERVER)