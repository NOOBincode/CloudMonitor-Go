package utils

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config 配置接口
type Config interface {
	Get(key string) interface{}
	GetString(key string) string
	GetInt(key string) int
	GetBool(key string) bool
}

// FileConfig 文件配置
type FileConfig struct {
	data map[string]interface{}
}

// NewFileConfig 创建文件配置
func NewFileConfig(filepath string) (*FileConfig, error) {
	data := make(map[string]interface{})

	ext := strings.ToLower(filepath[strings.LastIndex(filepath, ".")+1:])

	file, err := os.ReadFile(filepath)
	if err != nil {
		return nil, fmt.Errorf("read config file error: %v", err)
	}

	switch ext {
	case "json":
		err = json.Unmarshal(file, &data)
	case "yaml", "yml":
		err = yaml.Unmarshal(file, &data)
	default:
		return nil, fmt.Errorf("unsupported config file format: %s", ext)
	}

	if err != nil {
		return nil, fmt.Errorf("parse config file error: %v", err)
	}

	return &FileConfig{data: data}, nil
}

// Get 获取配置值
func (c *FileConfig) Get(key string) interface{} {
	return getNestedValue(c.data, key)
}

// GetString 获取字符串配置
func (c *FileConfig) GetString(key string) string {
	if v := c.Get(key); v != nil {
		if str, ok := v.(string); ok {
			return str
		}
	}
	return ""
}

// GetInt 获取整数配置
func (c *FileConfig) GetInt(key string) int {
	if v := c.Get(key); v != nil {
		switch val := v.(type) {
		case int:
			return val
		case float64:
			return int(val)
		}
	}
	return 0
}

// GetBool 获取布尔配置
func (c *FileConfig) GetBool(key string) bool {
	if v := c.Get(key); v != nil {
		if b, ok := v.(bool); ok {
			return b
		}
	}
	return false
}

// getNestedValue 获取嵌套值
func getNestedValue(data map[string]interface{}, key string) interface{} {
	keys := strings.Split(key, ".")
	current := data

	for _, k := range keys {
		if val, exists := current[k]; exists {
			if m, ok := val.(map[string]interface{}); ok {
				current = m
			} else {
				return val
			}
		} else {
			return nil
		}
	}

	return current
}
